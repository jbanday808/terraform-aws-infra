import os
import json
import time
import uuid
import logging
from typing import Any, Dict, Optional, Tuple

import boto3
from botocore.exceptions import ClientError

# -----------------------------
# Logging (CloudWatch-ready)
# -----------------------------
logger = logging.getLogger()
logger.setLevel(logging.INFO)

APP_ENV = os.getenv("APP_ENV", "dev")
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "http://localhost")
BEDROCK_REGION = os.getenv("BEDROCK_REGION", "us-east-1")
BEDROCK_MODEL_ID = os.getenv("BEDROCK_MODEL_ID", "")
BEDROCK_KB_ID = os.getenv("BEDROCK_KB_ID", "")

bedrock_runtime = boto3.client("bedrock-runtime", region_name=BEDROCK_REGION)


# -----------------------------
# Helpers
# -----------------------------
def _json_response(
    status_code: int,
    body: Dict[str, Any],
    origin: Optional[str] = None,
    request_id: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Standard HTTP response for API Gateway (HTTP API v2).
    Includes CORS + consistent JSON body.
    """
    headers = {
        "content-type": "application/json",
        "access-control-allow-methods": "GET,POST,OPTIONS",
        "access-control-allow-headers": "content-type,authorization",
    }

    # Basic CORS: reflect allowed origin if it matches list
    allowed = [o.strip() for o in ALLOWED_ORIGINS.split(",") if o.strip()]
    if origin and origin in allowed:
        headers["access-control-allow-origin"] = origin
    else:
        # fallback to first allowed origin (keeps local dev simple)
        headers["access-control-allow-origin"] = allowed[0] if allowed else "*"

    if request_id:
        headers["x-request-id"] = request_id

    return {
        "statusCode": status_code,
        "headers": headers,
        "body": json.dumps(body),
    }


def _parse_json_body(event: Dict[str, Any]) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
    """
    Parse JSON body safely.
    Returns (payload, error_message)
    """
    body = event.get("body")
    if body is None:
        return None, "Missing request body."

    # HTTP API may pass string; base64 support omitted for simplicity
    if isinstance(body, str):
        body = body.strip()
        if not body:
            return None, "Empty request body."
        try:
            return json.loads(body), None
        except json.JSONDecodeError:
            return None, "Invalid JSON body."
    elif isinstance(body, dict):
        return body, None

    return None, "Unsupported body format."


def _validate_chat_payload(payload: Dict[str, Any]) -> Tuple[Optional[str], Optional[str]]:
    """
    Validate input for POST /chat
    Expected: { "message": "..." }
    Returns (message, error_message)
    """
    message = payload.get("message")
    if not isinstance(message, str) or not message.strip():
        return None, "Field 'message' is required and must be a non-empty string."

    # Keep prompts reasonable
    if len(message) > 2000:
        return None, "Field 'message' is too long (max 2000 characters)."

    return message.strip(), None


def _extract_origin(event: Dict[str, Any]) -> Optional[str]:
    headers = event.get("headers") or {}
    # header casing can vary
    return headers.get("origin") or headers.get("Origin")


def _extract_claims(event: Dict[str, Any]) -> Dict[str, Any]:
    """
    For JWT-authorized routes, API Gateway includes claims in requestContext.authorizer.jwt.claims
    """
    rc = event.get("requestContext") or {}
    auth = (rc.get("authorizer") or {}).get("jwt") or {}
    return auth.get("claims") or {}


def _log_structured(level: str, record: Dict[str, Any]) -> None:
    """
    Emit JSON logs that are easy to query in CloudWatch Logs Insights.
    """
    record["level"] = level
    record["app_env"] = APP_ENV
    msg = json.dumps(record, default=str)

    if level == "ERROR":
        logger.error(msg)
    elif level == "WARN":
        logger.warning(msg)
    else:
        logger.info(msg)


def _bedrock_invoke_model(prompt: str, request_id: str) -> str:
    """
    Minimal Bedrock invocation using InvokeModel.
    NOTE: This is model-format dependent. We attempt a simple, generic JSON body.
    If your model requires a different schema, adjust the body below.
    """
    if not BEDROCK_MODEL_ID:
        raise ValueError("BEDROCK_MODEL_ID is not set.")
    if not BEDROCK_KB_ID:
        # Your KB is still useful for the overall project; this handler can still run without it
        # but you requested KB usage—so we enforce it for correctness.
        raise ValueError("BEDROCK_KB_ID is not set.")

    # This is a simple "grounded" instruction.
    # If you later wire actual Knowledge Base retrieval in code, you can add citations/context here.
    system_instruction = (
        "You are a private FAQ assistant. "
        "Answer clearly and briefly. "
        "If the answer is not in the approved knowledge base, say you don't know."
    )

    # Generic request payload (may need tuning depending on model)
    body = {
        "inputText": f"{system_instruction}\n\nUser question: {prompt}\n",
    }

    _log_structured("INFO", {
        "event": "bedrock_invoke_start",
        "request_id": request_id,
        "model_id": BEDROCK_MODEL_ID,
        "kb_id": BEDROCK_KB_ID,
    })

    try:
        resp = bedrock_runtime.invoke_model(
            modelId=BEDROCK_MODEL_ID,
            contentType="application/json",
            accept="application/json",
            body=json.dumps(body),
        )

        raw = resp["body"].read().decode("utf-8")
        data = json.loads(raw) if raw else {}

        # Try common response shapes
        answer = (
            data.get("outputText")
            or data.get("results", [{}])[0].get("outputText")
            or data.get("generation")
            or data.get("completion")
            or ""
        )

        answer = answer.strip() if isinstance(answer, str) else ""
        if not answer:
            answer = "I couldn't generate a response right now. Please try again."

        _log_structured("INFO", {
            "event": "bedrock_invoke_success",
            "request_id": request_id,
        })

        return answer

    except ClientError as e:
        _log_structured("ERROR", {
            "event": "bedrock_invoke_client_error",
            "request_id": request_id,
            "error": str(e),
        })
        raise

    except Exception as e:
        _log_structured("ERROR", {
            "event": "bedrock_invoke_unknown_error",
            "request_id": request_id,
            "error": str(e),
        })
        raise


# -----------------------------
# Handler (API Gateway v2)
# -----------------------------
def handler(event, context):
    request_id = getattr(context, "aws_request_id", None) or str(uuid.uuid4())
    start = time.time()

    method = (event.get("requestContext") or {}).get("http", {}).get("method", "")
    path = (event.get("requestContext") or {}).get("http", {}).get("path", "") or event.get("rawPath", "")
    origin = _extract_origin(event)

    _log_structured("INFO", {
        "event": "request_start",
        "request_id": request_id,
        "method": method,
        "path": path,
    })

    # CORS preflight
    if method == "OPTIONS":
        return _json_response(200, {"ok": True}, origin=origin, request_id=request_id)

    # Health endpoint pattern
    # You can create a separate API route GET /health and point it to this same Lambda.
    if method == "GET" and path.endswith("/health"):
        return _json_response(
            200,
            {
                "status": "ok",
                "env": APP_ENV,
                "bedrock_region": BEDROCK_REGION,
                "model_configured": bool(BEDROCK_MODEL_ID),
                "kb_configured": bool(BEDROCK_KB_ID),
            },
            origin=origin,
            request_id=request_id,
        )

    # Chat endpoint
    if method == "POST" and path.endswith("/chat"):
        payload, err = _parse_json_body(event)
        if err:
            return _json_response(400, {"error": err}, origin=origin, request_id=request_id)

        message, err = _validate_chat_payload(payload)
        if err:
            return _json_response(400, {"error": err}, origin=origin, request_id=request_id)

        # Optional: log the caller identity (from JWT claims)
        claims = _extract_claims(event)
        user_sub = claims.get("sub") or "unknown"
        _log_structured("INFO", {
            "event": "chat_request_validated",
            "request_id": request_id,
            "user_sub": user_sub,
        })

        try:
            answer = _bedrock_invoke_model(message, request_id=request_id)

            elapsed_ms = int((time.time() - start) * 1000)
            _log_structured("INFO", {
                "event": "request_success",
                "request_id": request_id,
                "elapsed_ms": elapsed_ms,
            })

            return _json_response(
                200,
                {
                    "request_id": request_id,
                    "answer": answer,
                },
                origin=origin,
                request_id=request_id,
            )

        except ValueError as e:
            # Config problems
            return _json_response(500, {"error": str(e)}, origin=origin, request_id=request_id)

        except ClientError:
            # Bedrock error
            return _json_response(502, {"error": "Bedrock request failed."}, origin=origin, request_id=request_id)

        except Exception:
            # Generic error
            return _json_response(500, {"error": "Unexpected server error."}, origin=origin, request_id=request_id)

    # Unknown route
    return _json_response(404, {"error": "Not found."}, origin=origin, request_id=request_id)
