# =============================================================================
# Terraform Configuration
# =============================================================================
terraform {
  # Minimum Terraform version required
  required_version = ">= 1.0"

  # ----------------------------------------------------------------------------
  # Required Providers
  # ----------------------------------------------------------------------------
  required_providers {
    # AWS Provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    # Archive Provider (for packaging Lambda code)
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }

    # Random Provider (for unique resource naming)
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# =============================================================================
# AWS Provider Configuration
# =============================================================================
provider "aws" {
  # ---------------------------------------------------------------------------
  # AWS Region (Pinned)
  # ---------------------------------------------------------------------------
  # Explicitly set to avoid interactive prompts
  region = "us-east-1"

  # ----------------------------------------------------------------------------
  # Default Resource Tags
  # ----------------------------------------------------------------------------
  default_tags {
    tags = {
      Project     = "ImageProcessingApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
