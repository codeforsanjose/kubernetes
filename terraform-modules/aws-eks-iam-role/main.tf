terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  tags = {
    application       = var.application
    environment       = var.environment
    terraform-managed = "True"
  }
}
