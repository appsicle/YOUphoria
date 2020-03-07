package routes

import (
	// Logging "../logging"

	"github.com/gorilla/mux"
)

// contain all routes
func ConnectRoutes(r * mux.Router){
	// Logging.Log.Info("Connecting routes")

	r.HandleFunc("/user", UserHandler)
	r.HandleFunc("/yelp", YelpHandler)
	r.HandleFunc("/profile/create", CreateProfileEndpoint).Methods("POST")
	r.HandleFunc("/profile/get", GetProfileEndpoint).Methods("GET")
	r.HandleFunc("/profile/update", UpdateProfileEndpoint).Methods("POST")
	r.HandleFunc("/profile/delete", DeleteProfileEndpoint).Methods("POST")
}