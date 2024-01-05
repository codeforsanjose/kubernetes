terraform {
  required_version = ">= 1.5.3"

  backend "s3" {
    bucket = "opensourcesanjose-terraform"
    key    = "eimmigrate/global.tfstate"
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
  application = "eimmigrate"

  region = "us-west-2"

  tags = {
    application       = local.application
    terraform-managed = "True"
  }
}
