terraform {
  required_version = ">= 1.5.3"

  backend "s3" {
    bucket = "codeforsanjose-terraform"
    key    = "aws-eks-cluster/prod.tfstate"
    region = "us-west-1"
    # dynamodb_table = "terraform-state-lock-dynamo"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

provider "aws" {
  region = local.region
}
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

provider "cloudflare" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

locals {
  application = "shared-cluster"
  environment = "prod"

  name = "${local.application}-${local.environment}"

  region   = "us-west-2"
  vpc_cidr = "10.1.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  cluster_version             = "1.27"
  eks-cluster-admin-role-name = "iam-user-group-admin"
  nginx_fullname_override     = "nginx-ingress"
  kubernetes_dashboard_url    = "k8s-dashboard.opensourcesanjose.org"

  cluster_admin_users = [
    "darren",
    "ehudiono",
  ]

  tags = {
    application       = local.application
    environment       = local.environment
    terraform-managed = "True"
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }

  registry {
    url      = "oci://public.ecr.aws"
    username = data.aws_ecrpublic_authorization_token.token.user_name
    password = data.aws_ecrpublic_authorization_token.token.password
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
