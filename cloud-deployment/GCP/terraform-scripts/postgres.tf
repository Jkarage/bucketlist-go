// provider "postgresql" {
//     alias            = "go_app_database"
//     host             = ""
//     port             = 5432
//     username         = "postgres"
//     password         = "1234567890"
//     sslmode          = "disable"
//     connect_timeout  = 15
//     expected_version = "9.6.0"
// }

// resource "postgresql_database" "go_main_database" {
//     provider          = "postgresql.go_app_database"
//     name              = "maindb"
//     template          = "template0"
//     lc_collate        = "DEFAULT"
//     connection_limit  = -1
//     allow_connections = true
//     encoding          = "DEFAULT"
//     lc_collate        = "DEFAULT"
// }

// resource "postgresql_database" "go_test_database" {
//     provider = "postgresql.go_app_database"
//     name              = "testdb"
//     template          = "template0"
//     lc_collate        = "DEFAULT"
//     connection_limit  = -1
//     allow_connections = true
//     encoding          = "DEFAULT"
//     lc_collate        = "DEFAULT"
// }

// // ===================================================================
// // ===================================================================



