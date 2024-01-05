variable "GOOGLE_SSO_CLIENT_ID" {
  type      = string
  sensitive = true
}
variable "GOOGLE_SSO_CLIENT_SECRET" {
  type      = string
  sensitive = true
}

data "cloudflare_zone" "opensourcesanjose" {
  name = "opensourcesanjose.org"
}

resource "cloudflare_record" "argocd_http" {
  zone_id = data.cloudflare_zone.opensourcesanjose.id
  name    = "argocd"
  value   = "${cloudflare_tunnel.this.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }
}

resource "helm_release" "argocd" {
  namespace = kubernetes_namespace.argocd.metadata[0].name

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  # Utilize Cloudflare Tunnel
  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  # Google SSO
  set {
    name  = "configs.cm.url"
    value = "https://argocd.opensourcesanjose.org"
  }
  set {
    name  = "configs.cm.oidc\\.tls\\.insecure\\.skip\\.verify"
    value = "true"
  }
  set_sensitive {
    name  = "configs.cm.dex\\.config"
    value = <<-YAML
      connectors:
      - type: oidc
        id: google
        name: Google
        config:
          issuer: https://accounts.google.com
          clientID: "${var.GOOGLE_SSO_CLIENT_ID}"
          clientSecret: "${var.GOOGLE_SSO_CLIENT_SECRET}"
    YAML
  }
  set {
    name  = "configs.rbac.create"
    value = "false"
  }
  # set {
  #   name  = "configs.rbac.policy\\.default"
  #   value = "role:readonly"
  # }

  # Enable Cluster Access via IRSA
  # https://github.com/argoproj/argo-cd/blob/ef7f32eb844739d8ae5b5feb987f32fa63024226/docs/operator-manual/declarative-setup.md
  # set {
  #   name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = aws_iam_role.argocd.arn
  # }
  # set {
  #   name  = "server.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = aws_iam_role.argocd.arn
  # }
  # set {
  #   name  = "global.securityContext.fsGroup"
  #   value = "999"
  # }
}

resource "kubernetes_config_map" "argcd_rbac" {
  metadata {
    name      = "argocd-rbac-cm"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    "policy.default" = "role:readonly"
    scopes           = "[email]"
    "policy.csv"     = <<-EOT
      p, role:org-admin, applications, *, */*, allow
      p, role:org-admin, clusters, get, *, allow
      p, role:org-admin, repositories, get, *, allow
      p, role:org-admin, repositories, create, *, allow
      p, role:org-admin, repositories, update, *, allow
      p, role:org-admin, repositories, delete, *, allow
      p, role:org-admin, projects, get, *, allow
      p, role:org-admin, projects, create, *, allow
      p, role:org-admin, projects, update, *, allow
      p, role:org-admin, projects, delete, *, allow
      p, role:org-admin, logs, get, *, allow
      p, role:org-admin, exec, create, */*, allow

      g, opensourcesanjose:admin, role:org-admin
    EOT
  }
}


# set {
#   name  = "configs.rbac.policy\\.csv"
#   value = <<-EOT
#     p, role:org-admin, applications, *, */*, allow
#     p, role:org-admin, clusters, get, *, allow
#     p, role:org-admin, repositories, get, *, allow
#     p, role:org-admin, repositories, create, *, allow
#     p, role:org-admin, repositories, update, *, allow
#     p, role:org-admin, repositories, delete, *, allow
#     p, role:org-admin, projects, get, *, allow
#     p, role:org-admin, projects, create, *, allow
#     p, role:org-admin, projects, update, *, allow
#     p, role:org-admin, projects, delete, *, allow
#     p, role:org-admin, logs, get, *, allow
#     p, role:org-admin, exec, create, */*, allow

#     g, opensourcesanjose:admin, role:org-admin
#   EOT
# }
