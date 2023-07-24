module "ecr" {
  source = "../../../modules/elastic-containter-repo"

  application = local.application
  aws_region  = local.region
}
