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
