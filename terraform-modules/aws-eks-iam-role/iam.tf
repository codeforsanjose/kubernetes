data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.aws_eks_cluster_name
}

locals {
  eks_cluster_oidc_issuer = trim(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://")
}

resource "aws_iam_policy" "this" {
  name   = "${var.application}-${var.environment}"
  path   = "/"
  policy = var.application_iam_policy_json
}

resource "aws_iam_role" "this" {
  name = "${var.application}-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_cluster_oidc_issuer}"
        }
        Condition = {
          StringEquals = {
            "${local.eks_cluster_oidc_issuer}:aud" = "sts.amazonaws.com"
            "${local.eks_cluster_oidc_issuer}:sub" = "system:serviceaccount:${var.application}-${var.environment}:${var.application}-${var.environment}"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
