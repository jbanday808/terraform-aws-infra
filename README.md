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

