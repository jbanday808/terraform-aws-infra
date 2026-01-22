#############################################
# variables.tf
#############################################

# -----------------------------
# Core
# -----------------------------
variable "environment" {
  description = "Environment name (dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
  default     = "private-faq-chatbot"
}

variable "allowed_origins" {
  description = "CORS allowed origins (your SPA URLs)."
  type        = list(string)
  default     = ["http://localhost"]
}

# -----------------------------
# Cognito (JWT Authorizer)
# -----------------------------
variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID."
  type        = string
}

variable "cognito_user_pool_client_id" {
  description = "Cognito App Client ID."
  type        = string
}

# -----------------------------
# Bedrock
# -----------------------------
variable "bedrock_kb_id" {
  description = "Bedrock Knowledge Base ID (from console)."
  type        = string
}

variable "bedrock_model_id" {
  description = "Bedrock Model ID (example: amazon.nova-lite-v1:0 or similar)."
  type        = string
}

# -----------------------------
# VPC
# -----------------------------
variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (2)."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

# -----------------------------
# EC2
# -----------------------------
variable "ec2_instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_pair_name" {
  description = "Existing EC2 key pair name in AWS (us-east-1)."
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to SSH (your public IP /32 recommended)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
