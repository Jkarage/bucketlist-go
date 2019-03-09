resource "google_compute_network" "main-network" {
  name = "${var.env_name}-main-network"
  description = "This is the base network for the go application instance and its database."
  // subnetworks_self_links = "${google_compute_subnetwork.go-app-private-subnetwork.name}"
}

resource "google_compute_subnetwork" "go-app-private-subnetwork" {
  name = "${var.env_name}-go-app-private-subnetwork"
  region = "${var.region}"
  network = "${google_compute_network.main-network.self_link}"
  ip_cidr_range = "${var.go_app_ip_cidr_range}"
  description = "This is the subnetwork the go application instance will reside in"
}

resource "google_compute_subnetwork" "postgres-db-private-subnetwork" {
  name = "${var.env_name}-postgres-db-private-subnetwork"
  region = "${var.region}"
  network = "${google_compute_network.main-network.self_link}"
  ip_cidr_range = "${var.postgres_db_ip_cidr_range}"
  description = "This is the subnetwork the postgres db instance will reside in"
}