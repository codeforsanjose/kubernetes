resource "helm_release" "metrics-server" {
  namespace        = "metrics-server"
  create_namespace = true

  name       = "metrics-server"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"

  set {
    name  = "apiService.create"
    value = "true"
  }
  set {
    name  = "rbac.create=true"
    value = "true"
  }
}
