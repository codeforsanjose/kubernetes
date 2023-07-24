resource "kubernetes_namespace" "this" {
  metadata {
    name = "${local.application}-${local.environment}"
    labels = {
      name = "${local.application}-${local.environment}"
    }
  }
}

module "doppler" {
  source = "../../../modules/eks-app-doppler-integration"

  namespace   = kubernetes_namespace.this.metadata[0].name
  application = local.application
  environment = local.environment
  aws_region  = local.aws_region
}

module "cloudflared_tunnel_dns" {
  source = "../../../modules/cloudflared-tunnel-dns"

  application    = local.application
  environment    = local.environment
  deployment_url = local.deployment_url
  cloudflare_tunnel_id = var.cloudflare_tunnel_id
}
