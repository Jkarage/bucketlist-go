resource "google_compute_backend_service" "web" {
  name = "${var.env_name}-go-app-lb"
  description = "GO app Load Balancer"
  port_name = "customhttp"
  protocol = "HTTP"
  enable_cdn = false

  backend {
    group = "${google_compute_instance_group_manager.go-app-server-group-manager.instance_group}"
  }
  session_affinity = "GENERATED_COOKIE"
  timeout_sec = 0

  health_checks = ["${google_compute_http_health_check.go-app-healthcheck.self_link}"]
}

resource "google_compute_instance_group_manager" "go-app-server-group-manager" {
  name = "${var.env_name}-go-app-server-group-manager"
  base_instance_name = "${var.env_name}-go-app-instance"
  instance_template = "${google_compute_instance_template.go-app-instance-template.self_link}"
  zone = "${var.zone}"
  update_strategy = "NONE"

  named_port {
    name = "customhttp"
    port = "${var.go_app_port}"
  }
}

resource "google_compute_instance_template" "go-app-instance-template" {
  name_prefix = "${var.env_name}-go-app-instance-template-"
  machine_type = "${var.machine_type}"
  region = "${var.region}"
  description = "Base template to create Go instances"
  instance_description = "Instance created from base template"
//   depends_on = ["google_sql_database_instance.vof-database-instance", "random_id.vof-db-user-password"]
  tags = ["${var.env_name}-go-app-server", "go-app-server"]

  network_interface {
    subnetwork = "${google_compute_subnetwork.go-app-private-subnetwork.name}"
    access_config {}
  }

  disk {
    source_image = "${var.go_disk_image}"
    auto_delete = true
    boot = true
    disk_type = "${var.go_disk_type}"
    disk_size_gb = "${var.go_disk_size}"
  }

  metadata {
    // databaseUser = "${random_id.vof-db-user.b64}"
    // databasePassword = "${random_id.vof-db-user-password.b64}"
    // databaseInstanceName = "${var.env_name}-vof-database-instance-${replace(lower(random_id.db-name.b64), "_", "-")}"
    // databaseHost = "${google_sql_database_instance.vof-database-instance.ip_address.0.ip_address}"
    // databasePort = "5432"
    // databaseName = "${var.env_name}-vof-database"
    bucketName = "${var.bucket}"
    // startup-script = "/home/vof/start_vof.sh"
    serial-port-enable = 1
  }

  lifecycle {
    create_before_destroy = true
  }

  # the email is the service account email whose service keys have all the roles suffiecient enough
  # for the project to interract with all the APIs it does interract with.
  # the scopes are those that we need for logging and monitoring, they are a must for logging to
  # be carried out.
  # the whole service account argument is required for identity and authentication reasons, if it is
  # not included here, the default service account is used instead.
  service_account {
    email = "${var.service_account_email}"
    scopes = ["https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/logging.read", "https://www.googleapis.com/auth/logging.write"]
  }
}

resource "google_compute_http_health_check" "go-app-healthcheck" {
  name = "${var.env_name}-go-app-healthcheck"
  port = "${var.go_app_port}"
  request_path = "${var.request_path}"
  check_interval_sec = "${var.check_interval_sec}"
  timeout_sec = "${var.timeout_sec}"
  unhealthy_threshold = "${var.unhealthy_threshold}"
  healthy_threshold = "${var.healthy_threshold}"
}

// this implements auto scaling depending on how you configure
resource "google_compute_autoscaler" "go-app-autoscaler" {
  name = "${var.env_name}-go-app-autoscaler"
  zone = "${var.zone}"
  target = "${google_compute_instance_group_manager.go-app-server-group-manager.self_link}"
  autoscaling_policy = {
    max_replicas = "${var.max_instances}"
    min_replicas = "${var.min_instances}"
    cooldown_period = 120
    cpu_utilization {
      target = 0.7
    }
  }
}


