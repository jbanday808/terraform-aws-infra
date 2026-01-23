# terraform-aws-infra – Private AI FAQ Chatbot on AWS

Private AI-powered FAQ chatbot infrastructure built with **Terraform on AWS**, using **Amazon Bedrock**, **AWS Lambda**, **API Gateway**, **Amazon Cognito**, **EC2**, and **VPC**.

---

## Quick Deployment

### 1. Prerequisites

Ensure the following are installed and configured:

- AWS account
- IAM user with required permissions
- Terraform `>= 1.0`
- AWS CLI configured
- Git + GitHub account
- Existing EC2 key pair

---

### 2. Clone the Repository

```bash
git clone https://github.com/jbanday808/terraform-aws-infra.git
cd terraform-aws-infra
```

### 3. Configure Terraform

```bash
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

**Required Configuration:**
```bash
environment     = "dev"
project_name    = "your-project-chatbot"
allowed_origins = ["http://localhost"]

# Cognito (JWT Authentication)
cognito_user_pool_id        = "us-east-1_XXXXXXXXX"
cognito_user_pool_client_id = "xxxxxxxxxxxxxxxxxxxx"

# Amazon Bedrock
bedrock_kb_id    = "XXXXXXXXXX"
bedrock_model_id = "amazon.nova-lite-v1:0"

# VPC
vpc_cidr = "10.10.0.0/16"
public_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

# EC2
ec2_instance_type = "t3.micro"
ec2_key_pair_name = "your-ec2-keypair-name"
ssh_allowed_cidrs = ["YOUR_PUBLIC_IP/32"]

```

### 4. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

**Deployment Time:** ~5-10 minutes

### 5. Access Application
```bash
# Get API Gateway endpoint
terraform output api_endpoint

# Get EC2 public IP
terraform output ec2_public_ip

# Get EC2 public DNS
terraform output ec2_public_dns

```

## Architecture

**Request Flow:**
User
  → Amazon Cognito (JWT Authentication)
    → API Gateway (HTTP API)
      → AWS Lambda
        → Amazon Bedrock Knowledge Base


**Deployed Resources:**
- API Gateway HTTP API
- API Gateway JWT Authorizer (Cognito)
- API Gateway Lambda integration
- API Gateway route: POST /chat
- API Gateway default stage ($default, auto-deploy)
- Lambda function (Python 3.12) + invoke permission from API Gateway
- IAM role for Lambda
- IAM policy for Bedrock invoke
- IAM policy attachments (Basic logging + Bedrock policy)
- VPC
- Internet Gateway
- 2 Public subnets (across 2 AZs)
- Public route table + default route to IGW
- Route table associations (2)
- EC2 security group (SSH inbound + all outbound)
- EC2 instance (Amazon Linux 2023)
- Random string suffix (unique naming)
- Archive packaging for Lambda (archive_file data source)
- Availability zones data source
- AMI lookup data source (Amazon Linux 2023)

## Update Infrastructure
```bash
terraform plan
terraform apply -auto-approve
```

## Troubleshooting

**Check Lambda logs:**
```bash
aws logs tail /aws/lambda/<lambda-function-name> --follow --region us-east-1
```

**Check Terraform backend:**
```bash
aws s3 ls s3://tf-state-backend-dev-001
aws dynamodb scan --table-name terraform-state-locks --region us-east-1
```

**Test API endpoint (example):**
```bash
curl -X POST "$API_ENDPOINT/chat" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <COGNITO_JWT_TOKEN>" \
  -d '{"message":"Hello"}'
```

**SSH to instances via bastion:**
```bash
chmod 400 private-faq-chatbot-ec2-key.pem
ssh -i private-faq-chatbot-ec2-key.pem ec2-user@EC2_PUBLIC_IP
```

## Cleanup

```bash
terraform destroy -auto-approve
```
**Key Learnings:**
- Terraform remote backend configuration with S3 and DynamoDB
- State locking and corruption recovery
- Secure JWT authentication with Amazon Cognito
- Serverless AI integration using Amazon Bedrock Knowledge Base (RAG)
- AWS networking and IAM best practices
- End-to-end DevOps lifecycle management

**Future Improvements:**
- GitHub Actions CI/CD pipeline
- Private subnets with NAT Gateway
- EC2 access via AWS SSM (no SSH)
- Custom domain and HTTPS
- Centralized logging and monitoring with CloudWatch
- WAF protection for API Gateway


