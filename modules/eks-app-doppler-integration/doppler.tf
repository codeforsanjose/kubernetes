data "aws_iam_role" "doppler" {
  name = "doppler-aws-integration-prod"
}

resource "doppler_environment" "this" {
  project = var.application
  slug    = var.environment
  name    = var.environment
}

resource "doppler_integration_aws_secrets_manager" "this" {
  name            = "${var.application}-${var.environment}"
  assume_role_arn = data.aws_iam_role.doppler.arn
}

resource "doppler_secrets_sync_aws_secrets_manager" "this" {
  integration = doppler_integration_aws_secrets_manager.this.id
  project     = var.application
  config      = var.environment

  region = var.aws_region
  path   = "/doppler/${var.application}/${var.environment}/"
}

resource "doppler_service_token" "this" {
  project = var.application
  config  = var.environment
  name    = "AWS EKS"
  access  = "read"
}

resource "kubernetes_secret" "doppler_token" {
  metadata {
    name      = "${var.application}-${var.environment}-doppler-token"
    namespace = "doppler-operator-system"
  }

  data = {
    serviceToken = doppler_service_token.this.key
  }
}

resource "kubectl_manifest" "doppler_secret" {
  yaml_body = <<-YAML
    ---
    apiVersion: secrets.doppler.com/v1alpha1
    kind: DopplerSecret
    metadata:
      name: dopplersecrets-${var.application}-${var.environment}
      namespace: "doppler-operator-system"
    spec:
      tokenSecret:
        name: ${var.application}-${var.environment}-doppler-token
      project: ${var.application}
      config: ${var.environment}
      managedSecret:
        name: ${var.application}-${var.environment}-doppler-secrets
        namespace: ${var.application}-${var.environment}
  YAML
}
