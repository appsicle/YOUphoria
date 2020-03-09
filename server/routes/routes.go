package routes

import (
	// Logging "../logging"
	Auth "../auth"

	mux "github.com/gorilla/mux"
)

// contain all routes
func ConnectRoutes(r * mux.Router){
	// Logging.Log.Info("Connecting routes")

	auth_r := r.PathPrefix("/").Subrouter()
	auth_r.Use(Auth.Middleware)

	r.HandleFunc("/profile/create", CreateProfileEndpoint).Methods("POST")
	r.HandleFunc("/profile/login", LoginProfileEndpoint).Methods("POST")
	auth_r.HandleFunc("/profile/getProfile", GetProfileEndpoint).Methods("GET")
	auth_r.HandleFunc("/profile/logout", LogoutProfileEndpoint).Methods("GET")
	auth_r.HandleFunc("/profile/update", UpdateProfileEndpoint).Methods("POST")
	auth_r.HandleFunc("/profile/delete", DeleteProfileEndpoint).Methods("GET")

	auth_r.HandleFunc("/backend/yelp", GetYelpResults).Methods("POST")
}