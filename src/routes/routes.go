// routes package contains all the API endpoints/routes
package routes

import (
	"github.com/gorilla/mux"
)

// InitRoutes initialises all routes in the routes package
func InitRoutes() *mux.Router {
	router := mux.NewRouter()
	SetAllUserRoutes(router)
	return router
}
