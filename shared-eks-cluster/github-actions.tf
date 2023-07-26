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

# data "tls_certificate" "github-actions" {
#   url = "https://token.actions.githubusercontent.com"
# }

# resource "aws_iam_openid_connect_provider" "github-actions" {
#   url             = "https://token.actions.githubusercontent.com"
#   client_id_list  = [
#     "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
#   ]
#   thumbprint_list = data.tls_certificate.this[0].certificates[*].sha1_fingerprint

#   tags = var.tags
# }

# data "aws_iam_policy_document" "github-actions" {
#   statement {
#     sid    = "GithubOidcAuth"
#     effect = "Allow"
#     actions = [
#       "sts:TagSession",
#       "sts:AssumeRoleWithWebIdentity"
#     ]

#     principals {
#       type        = "Federated"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
#     }

#     condition {
#       test     = "ForAllValues:StringEquals"
#       variable = "token.actions.githubusercontent.com:iss"
#       values   = ["http://token.actions.githubusercontent.com"]
#     }

#     condition {
#       test     = "ForAllValues:StringEquals"
#       variable = "token.actions.githubusercontent.com:aud"
#       values   = ["sts.amazonaws.com"]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "${local.provider_url}:sub"
#       values = [
#         "repo:codeforsanjose/e-immigrate"
#       ]
#     }
#   }
# }

# resource "aws_iam_role" "github-actions" {
#   name        = "github-actions"

#   assume_role_policy    = data.aws_iam_policy_document.this[0].json

#   tags = local.tags
# }

# resource "aws_iam_role_policy_attachment" "github-actions" {
#   role       = aws_iam_role.github-actions.name
#   policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
# }

# resource "aws_iam_role_policy_attachment" "github-actions" {
#   role       = aws_iam_role.github-actions.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
# }
