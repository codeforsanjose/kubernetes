module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CloudWatchLogsFullAccess     = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  }

  tags = local.tags
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  # version    = "v0.29.2"

  set {
    name  = "settings.aws.clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }

  set {
    name  = "replicas"
    value = "1"
  }
  set {
    name  = "controller.resources.requests.cpu"
    value = "0.25"
  }
  set {
    name  = "controller.resources.requests.memory"
    value = "64M"
  }
  set {
    name  = "controller.resources.limits.cpu"
    value = "0.25"
  }
  set {
    name  = "controller.resources.limits.memory"
    value = "256M"
  }

  lifecycle {
    ignore_changes = [repository_password]
  }
}

resource "kubernetes_manifest" "karpenter_provisioner" {
  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"

    metadata = {
      name = "default"
    }

    spec = {
      requirements = [
        {
          key      = "karpenter.sh/capacity-type",
          operator = "In"
          values   = ["on-demand"]
        },
        {
          key      = "kubernetes.io/arch",
          operator = "In"
          values   = ["amd64"]
        },
        {
          key      = "karpenter.k8s.aws/instance-family",
          operator = "In"
          values   = ["t3a"]
        },
        {
          key      = "kubernetes.io/os",
          operator = "In"
          values   = ["linux"]
        }
      ]
      limits = {
        resources = {
          cpu    = "50"
          memory = "50Gi"
        }
      }
      providerRef = {
        name = "default"
      }
      consolidation = {
        enabled = true
      }
      ttlSecondsUntilExpired = 86400
    }
  }

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubernetes_manifest" "karpenter_node_template" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1alpha1"
    kind       = "AWSNodeTemplate"

    metadata = {
      name = "default"
    }

    spec = {
      subnetSelector = {
        "karpenter.sh/discovery" = "${module.eks.cluster_name}"
      }
      securityGroupSelector = {
        "karpenter.sh/discovery" = "${module.eks.cluster_name}"
      }
      tags = {
        "karpenter.sh/discovery" = module.eks.cluster_name,
        Name                     = "eks-${local.application}-${local.environment}"
      }
      blockDeviceMappings = [
        {
          deviceName = "/dev/xvda",
          ebs = {
            volumeSize          = "100Gi"
            volumeType          = "gp3"
            encrypted           = true
            deleteOnTermination = true
          }
        },
      ]
      detailedMonitoring = true
    }
  }

  depends_on = [
    helm_release.karpenter
  ]
}
