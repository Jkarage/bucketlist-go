// Package routes contains all the API endpoints/routes
package routes

import (
	"controllers"

	"github.com/gorilla/mux"
)

// SetAllUserRoutes sets all the routes of users
func SetAllUserRoutes(router *mux.Router) *mux.Router {

	// Fetch all usere
	router.Handle("/user", controllers.JwtMiddleware.Handler(controllers.AllEndPoint)).Methods("GET")

	// Create a new user
	router.Handle("/signup", controllers.CreateEndPoint).Methods("POST")

	// Sign in a registered user
	router.HandleFunc("/signin", controllers.SignIn).Methods("POST")

	// Edit a user
	router.Handle("/user/{name}", controllers.JwtMiddleware.Handler(controllers.EditEndPoint)).Methods("PUT")

	// Delete a user
	router.Handle("/user/{name}", controllers.JwtMiddleware.Handler(controllers.DeleteEndPoint)).Methods("DELETE")

	// Search for a user
	router.Handle("/user/{name}", controllers.JwtMiddleware.Handler(controllers.SearchEndpoint)).Methods("GET")

	return router

}
