terraform {
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

locals {
  tags = {
    application       = var.application
    environment       = var.environment
    terraform-managed = "True"
  }

  # site_domain_name_parts = split(".", var.deployment_url)
  # len_site_domain_parts  = length(local.site_domain_name_parts)
  # site_subdomain         = join(".", slice(local.site_domain_name_parts, 0, local.len_site_domain_parts - 2))
  # parent_domain_list = [
  #   element(local.site_domain_name_parts, local.len_site_domain_parts - 2),
  #   element(local.site_domain_name_parts, local.len_site_domain_parts - 1)
  # ]
  # parent_domain          = join(".", local.parent_domain_list)
  # cloudflare_record_name = local.site_subdomain != "" ? local.site_subdomain : "@"
}
