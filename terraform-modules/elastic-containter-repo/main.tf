terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "this" {
  name = var.application

  tags = {
    app               = var.application
    terraform-managed = "True"
  }
}
