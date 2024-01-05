module "cloudflared_tunnel_dns" {
  source = "../terraform-modules/cloudflared-tunnel-dns"

  application          = local.application
  environment          = local.environment
  deployment_url       = local.kubernetes_dashboard_url
  cloudflare_tunnel_id = cloudflare_tunnel.this.id
}
