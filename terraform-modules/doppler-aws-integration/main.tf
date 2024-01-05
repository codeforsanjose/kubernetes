# https://docs.doppler.com/docs/aws-secrets-manager

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  application = "doppler-aws-integration"
  environment = "prod"

  tags = {
    application       = local.application
    environment       = local.environment
    terraform-managed = "True"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "AllowDopplerSecretsManagerAccess"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UpdateSecret"
    ]

    resources = ["arn:aws:secretsmanager:us-west-2:${data.aws_caller_identity.current.account_id}:secret:/doppler/*"]
  }
}

data "aws_iam_policy_document" "doppler" {
  statement {
    sid     = "AllowAssumeRoleForAnotherAccount"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["299900769157"] # Doppler AWS Account
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [var.doppler_workspace_id]
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = "${local.application}-${local.environment}"
  path   = "/"
  policy = data.aws_iam_policy_document.this.json

  tags = local.tags
}

resource "aws_iam_role" "this" {
  name               = "${local.application}-${local.environment}"
  assume_role_policy = data.aws_iam_policy_document.doppler.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

output "aws-integration-role-arn" {
  value = aws_iam_role.this.arn
}
