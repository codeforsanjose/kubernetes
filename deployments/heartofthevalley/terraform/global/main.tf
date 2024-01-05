terraform {
  required_version = ">= 1.5.3"

  backend "s3" {
    bucket = "opensourcesanjose-terraform"
    key    = "heartofthevalley/global.tfstate"
    region = "us-west-1"
    # dynamodb_table = "terraform-state-lock-dynamo"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    doppler = {
      source = "DopplerHQ/doppler"
    }
  }
}

provider "aws" {
  region = local.region
}

locals {
  application = "heartofthevalley"
  ecr_respositories = ["fronted", "backend", "graphql"]

  region = "us-west-2"

  tags = {
    application       = local.application
    terraform-managed = "True"
  }
}
