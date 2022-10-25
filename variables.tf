variable "services" {
  description = "Service APIs to enable."
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "appengine.googleapis.com",
    "firestore.googleapis.com",
    "spanner.googleapis.com",
    "pubsub.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com"
  ]
}

variable "spanner_project_id" {
  description = "ID of GCP project that houses the spanner instance to be auto scaled."
  type        = string
  default     = "dl-foladele-reference-infra-1"
}

variable "service_config" {
  description = "Configure service API activation."
  type = object({
    disable_on_destroy         = bool
    disable_dependent_services = bool
  })
  default = {
    disable_on_destroy         = true
    disable_dependent_services = true
  }
}
