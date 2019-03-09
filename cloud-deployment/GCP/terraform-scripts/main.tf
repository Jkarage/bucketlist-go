provider "google" {
  credentials = "${file("${var.credential_file}")}"
  project = "${var.project_id}"
  region = "${var.region}"
}

terraform {
  backend "gcs" {
    credentials = "../shared/terraform.json"
  }
}

data "terraform_remote_state" "go" {
  backend = "gcs"
  config {
    bucket = "${var.bucket}"
    path = "${var.state_path}"
    project = "${var.project_id}"
    credentials = "${file("${var.credential_file}")}"
  }
}
