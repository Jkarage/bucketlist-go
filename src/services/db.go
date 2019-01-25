package services

import (
	"fmt"
	"log"
	"os"

	"github.com/jinzhu/gorm"
	"github.com/joho/godotenv"

	// Postgres gorm driver
	_ "github.com/jinzhu/gorm/dialects/postgres"
)

// DbConnect connects the app to the database
func DbConnect() (*gorm.DB, error) {
	godotenv.Load()
	dbHost := os.Getenv("DB_HOST")
	dbName := os.Getenv("DB_DATABASE")
	dbUser := os.Getenv("DB_USER")
	dbPass := os.Getenv("DB_PASS")
	SSLMode := os.Getenv("SSL_MODE")
	dbType := os.Getenv("DB_TYPE")

	connectionString := fmt.Sprintf("host=%s user=%s dbname=%s sslmode=%s password=%s", dbHost, dbUser, dbName, SSLMode, dbPass)

	db, err := gorm.Open(dbType, connectionString)

	if err != nil {
		log.Fatalln("Error connecting to database", err)
		return nil, err
	}

	log.Println("DB Connection Successful")
	return db, nil
}
