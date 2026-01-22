terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Note: Provider configuration is intentionally not included
# Users should configure the AWS provider in their own environment
# Example:
#
# provider "aws" {
#   region = var.aws_region
# }
