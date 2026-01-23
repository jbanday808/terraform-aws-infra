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
- VPC with 8 subnets across 2 AZs (public, frontend, backend, database)
- Public ALB for internet traffic
- Internal ALB for backend communication
- Auto Scaling Groups (Frontend: 2-4, Backend: 2-6 instances)
- RDS PostgreSQL (Multi-AZ optional)
- NAT Gateway (1 or 2 for HA)
- Bastion host for SSH access
- Secrets Manager for credentials
- CloudWatch for logging

## Update Application

```bash
# Rebuild and push images
docker build -t YOUR_USERNAME/goal-tracker-frontend:latest ./frontend
docker push YOUR_USERNAME/goal-tracker-frontend:latest

# Trigger instance refresh
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name dev-goal-tracker-frontend-asg \
  --region us-east-1
```



