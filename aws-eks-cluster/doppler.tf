variable "DOPPLER_WORKSPACE_ID" {
  type      = string
  sensitive = true
}

resource "helm_release" "doppler-operator-system" {
  name       = "doppler-kubernetes-operator"
  repository = "https://helm.doppler.com"
  chart      = "doppler-kubernetes-operator"
}

module "doppler-aws-integration" {
  source = "../terraform-modules/doppler-aws-integration"

  doppler_workspace_id = var.DOPPLER_WORKSPACE_ID
}
