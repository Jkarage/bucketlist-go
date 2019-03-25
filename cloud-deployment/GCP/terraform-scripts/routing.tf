// URL maps route traffic to instances which are to serve the traffic on specific URL paths
resource "google_compute_url_map" "go-app-http-url-map" {
  name            = "${var.env_name}-go-app-url-map"
  default_service = "${google_compute_backend_service.web.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.web.self_link}"

    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.web.self_link}"
    }
  }
}


# Begin HTTP
resource "google_compute_global_forwarding_rule" "go-app-http" {
  name       = "${var.env_name}-go-app-http"
  ip_address = ""
  target     = "${google_compute_target_http_proxy.go-app-http-proxy.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "go-app-http-proxy" {
  name        = "${var.env_name}-go-app-proxy"
  url_map     = "${google_compute_url_map.go-app-http-url-map.self_link}"
}
# End HTTP

resource "google_compute_firewall" "go-app-public-firewall" {
  name = "${var.env_name}-go-app-public-firewall"
  network = "${google_compute_network.main-network.name}"

  allow {
    protocol = "tcp"
    ports = ["80", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["${var.env_name}-go-app-lb"]
}


resource "google_compute_firewall" "allow-ssh-to-go-app-public-firewall" {
  name = "allow-go-app-public-firewall"
  network = "${google_compute_network.main-network.name}"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["${var.env_name}-go-app-lb"]
}


resource "google_compute_firewall" "go-app-allow-healthcheck-firewall" {
  name = "${var.env_name}-go-app-allow-healthcheck-firewall"
  network = "${google_compute_network.main-network.name}"

  allow {
    protocol = "tcp"
    ports = ["${var.go_app_port}"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags = ["${var.env_name}-go-app-server", "go-app-server"]
}
// End of Go app instance firewall rules

// Allow SSH through network

resource "google_compute_firewall" "allow-ssh-firewall-rule" {
  name = "${var.env_name}-allow-ssh-firewall-rule"
  network = "${google_compute_network.main-network.name}"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["${var.env_name}-go-app-server", "go-app-server"]
}

