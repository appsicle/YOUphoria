package routes

import (
	"github.com/gorilla/mux"
)

// contain all routes
func ConnectRoutes(r * mux.Router){
	r.HandleFunc("/user", UserHandler)
	r.HandleFunc("/yelp", YelpHandler)
	r.HandleFunc("/profile/create", CreateProfileEndpoint).Methods("POST")
	r.HandleFunc("/profile/get", GetProfileEndpoint).Methods("GET")
	r.HandleFunc("/profile/update", UpdateProfileEndpoint).Methods("POST")
	r.HandleFunc("/profile/delete", DeleteProfileEndpoint).Methods("POST")
}