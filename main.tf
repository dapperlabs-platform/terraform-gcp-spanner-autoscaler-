terraform {
  backend "gcs" {
    bucket = "demo-infra"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "dl-foladele-reference-infra"
}

module "project" {
  source          = "github.com/dapperlabs-platform/terraform-google-project?ref=v0.9.0"
  name            = "dl-foladele-reference-infra"
  parent          = "folders/669925710268"
  billing_account = "01CF48-052610-ECCCA3"
  oslogin         = false

  services = [
    "cloudresourcemanager.googleapis.com",
    "cloudapis.googleapis.com",
    "container.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "gcp.redisenterprise.com"
  ]

  iam_additive = {
    "roles/container.admin" = [
      "group:sre@dapperlabs.com"
    ]
    "roles/viewer" = []

    "roles/cloudsql.client" = []
  }
}

## Enable required Cloud APIs
resource "google_project_service" "autoscaler_services" {
  for_each                   = toset(var.services)
  project                    = var.spanner_project_id
  service                    = each.value
  disable_on_destroy         = var.service_config.disable_on_destroy
  disable_dependent_services = var.service_config.disable_dependent_services
}

resource "google_app_engine_application" "app" {
  project     = var.spanner_project_id
  location_id = "us-central"
  database_type = "CLOUD_FIRESTORE"
}

resource "google_firestore_document" "autoscaler_doc" {
  project     = var.spanner_project_id
  collection  = "spannerAutoscaler"
  document_id = "autoscale-test"
  fields      =  ""
  depends_on = [google_app_engine_application.app]
}

# Auto Scaler Deployment
module "autoscale" {
  source = "./per-project-deployment"
  project_id = var.spanner_project_id
}
