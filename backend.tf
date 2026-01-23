#############################################
# Terraform Remote Backend Configuration
# Purpose: Store Terraform state remotely
#          using S3 with DynamoDB locking
#############################################

terraform {
  # ---------------------------------------------------------------------------
  # S3 Backend
  # ---------------------------------------------------------------------------
  backend "s3" {

    # LABEL: S3 bucket used to store the Terraform state file
    bucket = "tf-state-backend-dev-001"

    # LABEL: Unique state file path for this project and environment
    # (Prevents conflicts with other Terraform projects)
    key = "private-faq-chatbot/dev/terraform.tfstate"

    # LABEL: AWS region where the S3 bucket and DynamoDB table exist
    region = "us-east-1"

    # LABEL: DynamoDB table used for state locking and consistency
    dynamodb_table = "terraform-state-locks"

    # LABEL: Encrypt the Terraform state file at rest in S3
    encrypt = true
  }
}
