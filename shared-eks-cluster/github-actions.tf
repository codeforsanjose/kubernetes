resource "kubernetes_cluster_role" "github-actions" {
  metadata {
    name = "github-actions"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["list"]
  }
}

resource "kubernetes_cluster_role_binding" "github-actions" {
  metadata {
    name = "github-actions"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "github-actions"
  }
  subject {
    kind      = "User"
    name      = "github-actions"
    namespace = "kube-system"
    api_group = "rbac.authorization.k8s.io"
  }
}
