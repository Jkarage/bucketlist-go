package main

import (
	"log"
	"net/http"
	"os"
	"routes"

	"github.com/gorilla/handlers"
)

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
