module "ecr" {
  source = "../../../../terraform-modules/elastic-containter-repo"

  application = local.application
  aws_region  = local.region
}
