variable "doppler_workspace_id" {
  type      = string
  sensitive = true
}

resource "helm_release" "doppler-operator-system" {
  namespace        = "doppler-operator-system"
  create_namespace = true

  name       = "doppler-kubernetes-operator"
  repository = "https://helm.doppler.com"
  chart      = "doppler-kubernetes-operator"
}

module "doppler-aws-integration" {
  source = "../modules/doppler-aws-integration"

  doppler_workspace_id = var.doppler_workspace_id
}
