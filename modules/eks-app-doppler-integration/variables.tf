variable "namespace" {
  type = string
}

variable "application" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

# variable "deployment_url" {
#   type = string
# }

# variable "aws_eks_cluster_name" {
#   type = string
# }

# variable "vpc_id" {
#   type = string
# }
