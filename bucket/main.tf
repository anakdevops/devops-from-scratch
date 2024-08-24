provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

resource "google_storage_bucket" "my_bucket" {
  name     = "my-devops-data"
  location = var.region
  force_destroy  = true
}

output "bucket_name" {
  value = google_storage_bucket.my_bucket.name
}