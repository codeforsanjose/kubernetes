data "cloudflare_accounts" "this" {}

resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "this" {
  account_id = data.cloudflare_accounts.this.accounts[0].id
  name       = "eks-${local.application}-${local.environment}"
  secret     = random_id.tunnel_secret.b64_std
}

resource "kubectl_manifest" "namespace-cloudflared" {
  yaml_body = <<-YAML
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
      name: cloudflared
  YAML
}

resource "kubectl_manifest" "cloudflared_tunnel_token" {
  yaml_body = <<-YAML
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: cloudflared
      namespace: cloudflared
    data:
      TUNNEL_TOKEN: ${base64encode(cloudflare_tunnel.this.tunnel_token)}
  YAML
}

resource "kubernetes_config_map" "cloudflared" {
  metadata {
    name      = "cloudflared"
    namespace = "cloudflared"
  }

  data = {
    "config.yaml" = <<YAML
tunnel: ${cloudflare_tunnel.this.id}
metrics: 0.0.0.0:2000
no-autoupdate: true
ingress:
- service: http://${local.nginx_fullname_override}-controller.${helm_release.nginx_ingress.namespace}.svc.cluster.local:80
YAML
  }
}

resource "kubernetes_deployment" "cloudflared" {
  metadata {
    name      = "cloudflared"
    namespace = "cloudflared"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "cloudflared"
      }
    }

    template {
      metadata {
        labels = {
          app = "cloudflared"
        }
      }

      spec {

        volume {
          name = "config"
          config_map {
            name = "cloudflared"
          }
        }

        container {
          image = "cloudflare/cloudflared:2023.7.0"
          name  = "cloudflared"
          args  = ["tunnel", "--config", "/etc/cloudflared/config/config.yaml", "run"]

          liveness_probe {
            http_get {
              path = "/ready"
              port = 2000
            }

            initial_delay_seconds = 1
            period_seconds        = 10
            failure_threshold     = 1
          }

          env_from {
            secret_ref {
              name = "cloudflared"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/cloudflared/config"
            read_only  = true
          }

          resources {
            requests = {
              cpu    = "1000m"
              memory = "2048Mi"
            }
          }
        }
      }
    }
  }
}

