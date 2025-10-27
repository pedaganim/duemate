terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Backend configuration for production environment
  # MUST be configured for production
  # backend "s3" {
  #   bucket         = "duemate-terraform-state-production"
  #   key            = "production/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "duemate-terraform-locks-production"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "duemate"
      Environment = "production"
      ManagedBy   = "Terraform"
      Compliance  = "Required"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "duemate"
      Environment = "production"
      ManagedBy   = "Terraform"
      Compliance  = "Required"
    }
  }
}
