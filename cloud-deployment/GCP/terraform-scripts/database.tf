

resource "random_id" "go-db-user" {
  byte_length = 8
}

resource "random_id" "go-db-user-password" {
  byte_length = 16
}

resource "google_sql_database_instance" "go-database-vm-instance" {
  region = "${var.region}"
  database_version = "POSTGRES_9_6"
  name = "${var.env_name}-go-database-vm-instance"
  project = "${var.project_id}"

  settings {
    tier = "${var.db_instance_tier}"
    availability_type = "REGIONAL"
    disk_autoresize = true
    ip_configuration = {
      ipv4_enabled = true

      authorized_networks = [{
        name = "all"
        value = "0.0.0.0/0"
      }]
    }

    backup_configuration {
      binary_log_enabled = true
      enabled = true
      start_time = "${var.db_backup_start_time}"
    }
  }
}

resource "google_sql_database" "go-main-database" {
  name = "${var.env_name}-go-main-database"
  instance = "${google_sql_database_instance.go-database-vm-instance.name}"
  charset = "UTF8"
  collation = "en_US.UTF8"
}

resource "google_sql_database" "go-test-database" {
  name = "${var.env_name}-go-test-database"
  instance = "${google_sql_database_instance.go-database-vm-instance.name}"
  charset = "UTF8"
  collation = "en_US.UTF8"
}

resource "google_sql_user" "go-database-user" {
  name = "${random_id.go-db-user.b64}"
  password = "${random_id.go-db-user-password.b64}"
  instance = "${google_sql_database_instance.go-database-vm-instance.name}"
  host = ""
}
