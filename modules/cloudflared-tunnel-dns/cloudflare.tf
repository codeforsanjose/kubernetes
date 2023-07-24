resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.this.id
  name    = local.site_subdomain == "" ? "www" : "www.${local.site_subdomain}"
  value   = "${var.cloudflare_tunnel_id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "site" {
  zone_id = data.cloudflare_zone.this.id
  name    = local.cloudflare_record_name
  value   = "${var.cloudflare_tunnel_id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
