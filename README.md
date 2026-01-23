# terraform-aws-infra

Production-ready **DevOps infrastructure** built with **Terraform on AWS**, implementing a secure **private AI-powered FAQ chatbot** using **Amazon Bedrock**, **Lambda**, **API Gateway**, **Cognito**, **EC2**, and **VPC**.

---

## 🚀 Project Overview

This project demonstrates an **end-to-end DevOps workflow**:
- Git-based version control
- Infrastructure as Code (IaC) with Terraform
- Secure AWS backend state management
- Cloud-native AI integration
- Full lifecycle management (deploy → destroy)

The infrastructure supports a **private Retrieval-Augmented Generation (RAG) chatbot** backed by an **Amazon Bedrock Knowledge Base**, protected with **JWT authentication via Cognito**.

---

## 🏗️ Architecture

**High-level flow:**

User
→ Amazon Cognito (JWT Auth)
→ API Gateway (HTTP API)
→ AWS Lambda
→ Amazon Bedrock Knowledge Base


**Infrastructure components:**
- VPC with public subnets
- EC2 instance for admin / DevOps access
- IAM roles and policies (least privilege)
- Remote Terraform backend (S3 + DynamoDB locking)

---

## 📁 Repository Structure

terraform-aws-infra/
├── backend.tf # Remote state (S3 + DynamoDB)
├── provider.tf # AWS provider configuration
├── main.tf # API Gateway, Lambda, Bedrock integration
├── variables.tf # Input variables
├── terraform.tfvars.example# Safe example variables (no secrets)
├── vpc.tf # VPC, subnets, routing
├── ec2.tf # EC2 instance + security group
├── outputs.tf # Terraform outputs
├── lambda/
│ └── app.py # Lambda handler
└── README.md


---

## 🔐 Security Best Practices

- No secrets committed to GitHub
- Sensitive values stored in `terraform.tfvars` (gitignored)
- Terraform state encrypted in S3
- DynamoDB state locking enabled
- SSH access restricted to a single IP (`/32`)
- IAM roles scoped with least privilege

---

## 🧰 Prerequisites

- AWS Account
- IAM user with required permissions
- Terraform `>= 1.0`
- AWS CLI configured
- Git + GitHub account

---

## ⚙️ Setup & Deployment

### 1️⃣ Clone the repository
```bash
git clone https://github.com/jbanday808/terraform-aws-infra.git
cd terraform-aws-infra

---

Create local variables file:

cp terraform.tfvars.example terraform.tfvars

Update terraform.tfvars with:

Cognito User Pool ID

App Client ID

Bedrock Knowledge Base ID

EC2 key pair name

SSH CIDR

⚠️ Do NOT commit terraform.tfvars
---


