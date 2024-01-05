terraform {
  required_version = ">= 1.5.3"

  backend "s3" {
    bucket = "opensourcesanjose-terraform"
    key    = "happeningatm/prod.tfstate"
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
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "aws" {}

locals {
  application      = "happeningatm"
  environment      = "prod"
  deployment_url   = "happeningatm.opensourcesanjose.org"
  aws_region       = "us-west-2"
  eks_cluster_name = "shared-cluster-prod"

  tags = {
    application       = local.application
    environment       = local.environment
    terraform-managed = "True"
  }
}

data "aws_eks_cluster" "this" {
  name = local.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.this.id]
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.this.id]
  }
}
