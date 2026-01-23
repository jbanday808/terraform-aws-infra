# terraform-aws-infra

![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazonaws)
![IaC](https://img.shields.io/badge/Infrastructure%20as%20Code-IaC-blue)
![CI](https://img.shields.io/badge/CI-Coming%20Soon-lightgrey)

Production-ready **DevOps infrastructure** built with **Terraform on AWS**, implementing a secure **private AI-powered FAQ chatbot** using **Amazon Bedrock**, **AWS Lambda**, **API Gateway**, **Amazon Cognito**, **EC2**, and **VPC**.

---

## 🚀 Project Overview

This project demonstrates an **end-to-end DevOps workflow**:

- Git-based version control and branching  
- Infrastructure as Code (IaC) using Terraform  
- Secure remote state management (S3 + DynamoDB)  
- Cloud-native AI integration with Amazon Bedrock  
- Full infrastructure lifecycle (deploy → destroy)  

The solution supports a **private Retrieval-Augmented Generation (RAG) chatbot**, protected by **JWT authentication via Amazon Cognito**.

---

## 🏗️ Architecture

### High-level flow

```text
User
  → Amazon Cognito (JWT Authentication)
    → API Gateway (HTTP API)
      → AWS Lambda
        → Amazon Bedrock Knowledge Base

---

## 🧱 Infrastructure Components

- VPC with public subnets  
- EC2 instance for admin / DevOps access  
- IAM roles and policies following least-privilege principles  
- Remote Terraform backend using S3 for state storage and DynamoDB for state locking  

---
