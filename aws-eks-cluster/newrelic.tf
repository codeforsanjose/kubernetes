variable "NEWRELIC_LICENSE_KEY" {
  type      = string
  sensitive = true
}

resource "kubernetes_namespace" "newrelic" {
  metadata {
    name = "newrelic"
    labels = {
      name = "newrelic"
    }
  }
}

resource "helm_release" "newrelic" {
  namespace = kubernetes_namespace.newrelic.metadata[0].name

  repository = "https://helm-charts.newrelic.com"
  name       = "newrelic-bundle"
  chart      = "nri-bundle"

  set {
    name  = "global.cluster"
    value = module.eks.cluster_name
  }
  set_sensitive {
    name  = "global.licenseKey"
    value = var.NEWRELIC_LICENSE_KEY
  }
  set {
    name  = "newrelic-infrastructure.privileged"
    value = "true"
  }
  set {
    name  = "global.lowDataMode"
    value = "true"
  }
  set {
    name  = "global.fargate"
    value = "true"
  }

  # Metrics
  set {
    name  = "kube-state-metrics.image.tag"
    value = "v2.7.0"
  }
  set {
    name  = "kube-state-metrics.enabled"
    value = "true"
  }
  set {
    name  = "kubeEvents.enabled"
    value = "true"
  }

  # Logs
  set {
    name  = "logging.enabled"
    value = "true"
  }
  set {
    name  = "newrelic-logging.lowDataMode"
    value = "true"
  }

  # fargate
  set {
    name  = "newrelic-infra-operator.enabled"
    value = "true"
  }
}
