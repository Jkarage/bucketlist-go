package main

import (
	"log"
	"net/http"
	"os"

	"github.com/davidmukiibi/controllers"
	"github.com/davidmukiibi/routes"
	"github.com/davidmukiibi/services"

	"github.com/gorilla/handlers"
)

// Migrate function helps with the database migrations
func Migrate() {
	db, _ := services.DbConnect()
	defer db.Close()
	if err := db.AutoMigrate(&controllers.User{}).Error; err != nil {
		log.Fatalln("Error migrating the database ", err.Error())
	} else {
		log.Println("Migration successful...")
	}
}

// init is going to have the DB connections and any one-time tasks
func init() {
	Migrate()
}

// Define HTTP request routes
func main() {
	router := routes.InitRoutes()
	log.Fatal(http.ListenAndServe(":3000", handlers.LoggingHandler(os.Stdout, router)))
}

/* Handlers */
// var GetTokenHandler = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
// 	/* Create the token */
// 	token := jwt.New(jwt.SigningMethodHS256)

// 	// Create a map to store our claims
// 	claims := token.Claims.(jwt.MapClaims)

// 	/* Set token claims */
// 	claims["admin"] = false
// 	claims["email"] = user.UserEmail
// 	claims["exp"] = time.Now().Add(time.Hour * 24).Unix()

// 	/* Sign the token with our secret */
// 	tokenString, _ := token.SignedString(mySigningKey)

// 	/* Finally, write the token to the browser window */
// 	w.Write([]byte(tokenString))
// })

// Proper error handling and display in a more meaningful way
