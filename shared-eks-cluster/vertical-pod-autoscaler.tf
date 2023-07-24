# Vertical Pod Autoscaler
# https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler

# resource "helm_release" "metrics-server" {
#   namespace        = "metrics-server"
#   create_namespace = true

#   name       = "metrics-server"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "metrics-server"

#   set {
#     name  = "apiService.create"
#     value = "true"
#   }
#   set {
#     name  = "rbac.create=true"
#     value = "true"
#   }
# }

# resource "helm_release" "vpa" {
#   namespace        = "vpa"
#   create_namespace = true

#   name       = "fairwinds-stable"
#   repository = "https://charts.fairwinds.com/stable"
#   chart      = "vpa"

#   depends_on = [helm_release.metrics-server]
# }
