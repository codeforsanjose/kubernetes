resource "kubernetes_namespace" "kubernetes-dashboard" {
  metadata {
    name = "kubernetes-dashboard"
    labels = {
      name = "kubernetes-dashboard"
    }
  }
}

# https://github.com/kubernetes/dashboard/blob/master/charts/helm-chart/kubernetes-dashboard/values.yaml
# Also installs these other helm charts
# - metrics-server
# - cert-manager
resource "helm_release" "kubernetes-dashboard" {
  namespace        = kubernetes_namespace.kubernetes-dashboard.metadata[0].name

  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"

  set {
    name  = "nginx.enabled"
    value = "false"
  }
  set_list {
    name  = "app.ingress.hosts"
    value = [local.kubernetes_dashboard_url]
  }
  set_list {
    name  = "api.containers.args"
    value = ["--enable-skip-login"]
  }
}

resource "kubernetes_service_account" "kubernetes-dashboard" {
  metadata {
    name = "kubernetes-dashboard-admin-user"
    namespace = kubernetes_namespace.kubernetes-dashboard.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "kubernetes-dashboard" {
  metadata {
    name = "kubernetes-dashboard-admin-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard-admin-user"
    namespace = kubernetes_namespace.kubernetes-dashboard.metadata[0].name
  }
}

resource "kubernetes_secret" "kubernetes-dashboard" {
  metadata {
    name      = "kubernetes-dashboard-admin-user-token"
    namespace = kubernetes_namespace.kubernetes-dashboard.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = "kubernetes-dashboard-admin-user"
    }
  }
  type = "kubernetes.io/service-account-token"
}
