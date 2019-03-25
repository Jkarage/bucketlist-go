variable "region" {
  type = "string"
  default = "europe-west1"
}

variable "zone" {
  type = "string"
  default = "europe-west1-b"
}

variable "bucket" {
  type = "string"
  default = "terraform-admin-123000999"
}

variable "base_image" {
  type = "string"
  default = "ubuntu-1604-xenial-v20170815a"
}

variable "project_id" {
  type = "string"
  default = "terraform-admin-123000999"
}

variable "machine_type" {
  type = "string"
  default = "n1-standard-1"
}

variable "small_machine_type" {
  type = "string"
  default = "g1-small"
}

variable "credential_file" {
  type = "string"
  default = "../shared/terraform.json"
}

variable "env_name" {
  type = "string"
  default = "dev"
}

variable "state_path" {
  type = "string"
  default = "terraform-admin-123000999/default.tfstate"
}

variable "max_instances" {
  type = "string"
  default = "2"
}

variable "min_instances" {
  type = "string"
  default = "1"
}

variable "go_disk_image" {
  type = "string"
  default = "dev-go-app-image-1553501527"
}

variable "go_disk_type" {
  type = "string"
  default = "pd-ssd"
}

variable "go_disk_size" {
  type = "string"
  default = "10"
}

variable "request_path" {
  type = "string"
  default = "/"
}

variable "check_interval_sec" {
  type = "string"
  default = "2"
}

variable "unhealthy_threshold" {
  type = "string"
  default = "2"
}

variable "healthy_threshold" {
  type = "string"
  default = "2"
}

variable "timeout_sec" {
  type = "string"
  default = "2"
}

variable "go_app_ip_cidr_range" {
  type = "string"
  default = "10.0.0.0/29"
}

variable "service_account_email" {
  type = "string"
  default = "terraform@terraform-admin-123000999.iam.gserviceaccount.com"
}

variable "go_app_port" {
  type = "string"
  default = "3000"
}

