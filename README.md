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

The infrastructure supports a **private Retrieval-Augmented Generation (RAG) chatbot** backed by an **Amazon Bedrock Knowledge Base**, protected with **JWT authentication via Amazon Cognito**.

---

## 🏗️ Architecture

### High-level flow

```text
User
  → Amazon Cognito (JWT Authentication)
    → API Gateway (HTTP API)
      → AWS Lambda
        → Amazon Bedrock Knowledge Base
## 🧱 Infrastructure Components

- **VPC** with public subnets  
- **EC2 instance** for admin / DevOps access  
- **IAM roles and policies** following least-privilege principles  
- **Remote Terraform backend** using S3 for state storage and DynamoDB for state locking  

---

## 📁 Repository Structure

```text
terraform-aws-infra/
├── backend.tf                 # Remote state (S3 + DynamoDB)
├── provider.tf                # AWS provider configuration
├── main.tf                    # API Gateway, Lambda, Bedrock integration
├── variables.tf               # Input variables
├── terraform.tfvars.example   # Safe example variables (no secrets)
├── vpc.tf                     # VPC, subnets, routing
├── ec2.tf                     # EC2 instance + security group
├── outputs.tf                 # Terraform outputs
├── lambda/
│   └── app.py                 # Lambda handler
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

- AWS account  
- IAM user with required permissions  
- Terraform `>= 1.0`  
- AWS CLI configured  
- Git and GitHub account  

---

## ⚙️ Setup & Deployment

### 1️⃣ Clone the repository

```bash
git clone https://github.com/jbanday808/terraform-aws-infra.git
cd terraform-aws-infra


### 2️⃣ Create local variables file

```bash
cp terraform.tfvars.example terraform.tfvars
### Update `terraform.tfvars` with the following values

Edit your local `terraform.tfvars` file and provide:

- Cognito User Pool ID  
- App Client ID  
- Bedrock Knowledge Base ID  
- EC2 key pair name  
- SSH CIDR  

> ⚠️ **Do NOT commit `terraform.tfvars`**  
> This file contains environment-specific and sensitive values.

---

### 3️⃣ Initialize Terraform

```bash
terraform init
---

### 4️⃣ Validate and plan

```bash
terraform validate
terraform plan

---

### 5️⃣ Deploy infrastructure

```bash
terraform apply -auto-approve

---

### 6️⃣ View outputs

```bash
terraform output

---
## 🧹 Cleanup (Destroy Infrastructure)

```bash
terraform destroy -auto-approve

---


## 📌 Key Learnings

- Real-world Git branching and commits  
- Terraform remote backend configuration  
- State locking and corruption recovery  
- AWS IAM and security hardening  
- AI integration with serverless architectures  
- Full DevOps lifecycle management  

---

## 🛠️ Future Improvements

- GitHub Actions CI/CD pipeline  
- Private subnets with NAT Gateway  
- EC2 access via AWS SSM (no SSH)  
- Custom domain and HTTPS  
- Centralized logging and monitoring (CloudWatch)  

---


