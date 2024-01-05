module "doppler_project" {
  source = "../../../../terraform-modules/doppler-project"

  project_name = local.application
}
