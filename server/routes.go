package main

import (
	// Logging "../logging"
	mux "github.com/gorilla/mux"
)

// contain all routes
func ConnectRoutes(r * mux.Router){
	// Logging.Log.Info("Connecting routes")

	auth_r := r.PathPrefix("/").Subrouter()
	auth_r.Use(Middleware)

	r.HandleFunc("/profile/create", CreateProfileEndpoint).Methods("POST")
	r.HandleFunc("/profile/login", LoginProfileEndpoint).Methods("POST")
	auth_r.HandleFunc("/profile/getProfile", GetProfileEndpoint).Methods("GET")
	auth_r.HandleFunc("/profile/logout", LogoutProfileEndpoint).Methods("GET")
	auth_r.HandleFunc("/profile/update", UpdateProfileEndpoint).Methods("POST")
	auth_r.HandleFunc("/profile/delete", DeleteProfileEndpoint).Methods("GET")

	auth_r.HandleFunc("/mood/addMood", AddMoodEndpoint).Methods("POST")
	auth_r.HandleFunc("/mood/getAllMoods", getAllMoodsEndpoint).Methods("GET")
	auth_r.HandleFunc("/mood/getMoodsForDay", GetMoodsForDayEndpoint).Methods("POST")



	auth_r.HandleFunc("/backend/yelp", GetYelpResults).Methods("POST")

	auth_r.HandleFunc("/recommendation/getRecommendation", GetRecommendationEndpoint).Methods("POST")
	auth_r.HandleFunc("/recommendation/sendUserInterests", SendUserInterestsEndpoint).Methods("POST")
	auth_r.HandleFunc("/recommendation/getUserInterests", GetUserInterestsEndpoint).Methods("GET")
	auth_r.HandleFunc("/recommendation/addRecommendationFeedback", AddRecommendationFeedbackEndpoint).Methods("POST")

}