terraform {
  required_providers {
    doppler = {
      source = "DopplerHQ/doppler"
    }
  }
}

resource "doppler_project" "this" {
  name = var.project_name
}
