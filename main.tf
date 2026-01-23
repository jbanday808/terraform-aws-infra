#############################################
# main.tf
# Purpose: API Gateway (JWT/Cognito) -> Lambda -> Bedrock
#############################################

# -----------------------------
# Random suffix (unique names)
# -----------------------------
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  name_prefix = "${var.project_name}-${var.environment}-${random_string.suffix.result}"
}

# -----------------------------
# Package Lambda code (zip)
# NOTE: create ./lambda/app.py before apply
# -----------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/build/lambda.zip"
}

# -----------------------------
# IAM Role for Lambda
# -----------------------------
resource "aws_iam_role" "lambda_role" {
  name = "${local.name_prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Basic logging
resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Bedrock Invoke permissions
resource "aws_iam_policy" "lambda_bedrock_policy" {
  name        = "${local.name_prefix}-lambda-bedrock"
  description = "Allow Lambda to call Bedrock models."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "AllowBedrockInvoke",
      Effect = "Allow",
      Action = [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_bedrock_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_bedrock_policy.arn
}

# -----------------------------
# Lambda Function
# -----------------------------
resource "aws_lambda_function" "chatbot" {
  function_name = "${local.name_prefix}-chatbot"
  role          = aws_iam_role.lambda_role.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "app.handler"
  runtime          = "python3.12"
  timeout          = 30
  memory_size      = 512

  environment {
    variables = {
      BEDROCK_REGION   = "us-east-1"
      BEDROCK_MODEL_ID = var.bedrock_model_id
      BEDROCK_KB_ID    = var.bedrock_kb_id
      ALLOWED_ORIGINS  = join(",", var.allowed_origins)
      APP_ENV          = var.environment
    }
  }
}

# -----------------------------
# API Gateway HTTP API
# -----------------------------
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.allowed_origins
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type", "authorization"]
  }
}

# -----------------------------
# JWT Authorizer (Cognito)
# -----------------------------
resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id           = aws_apigatewayv2_api.http_api.id
  name             = "${local.name_prefix}-jwt"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]
    issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

# -----------------------------
# API Gateway → Lambda Integration
# -----------------------------
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.chatbot.invoke_arn
  payload_format_version = "2.0"
}

# -----------------------------
# Route: POST /chat (JWT protected)
# -----------------------------
resource "aws_apigatewayv2_route" "chat" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /chat"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
}

# -----------------------------
# Route: GET /health (NO AUTH)
# -----------------------------
resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /health"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"

  authorization_type = "NONE"
}

# -----------------------------
# Default Stage (auto deploy)
# -----------------------------
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# -----------------------------
# Allow API Gateway to invoke Lambda
# -----------------------------
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
