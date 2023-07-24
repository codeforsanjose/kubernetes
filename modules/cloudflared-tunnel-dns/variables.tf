variable "application" {
  type = string
}

variable "environment" {
  type = string
}

variable "deployment_url" {
  type = string
}

variable "cloudflare_tunnel_id" {
  type = string
  sensitive = true
}
