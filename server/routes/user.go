package routes

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	// "go.mongodb.org/mongo-driver/mongo/options"
)

func UserHandler(w http.ResponseWriter, r *http.Request){
	fmt.Fprintf(w, "User")
}

// Profile is...
type Profile struct {
	ID        primitive.ObjectID `json:"id"`
	UserName  string             `json:"user"`
	Email     string             `json:"email"`
	FullName  string             `json:"name"`
	CreatedOn string             `json:"createdOn"`
}


// CreateProfileEndpoint is...
func CreateProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	var profile Profile
	profile.ID = primitive.NewObjectID()
	json.NewDecoder(req.Body).Decode(&profile)
	collection := client.Database("YOUphoria").Collection("profiles")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if _, err := collection.InsertOne(ctx, profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
	}
	json.NewEncoder(res).Encode(profile)
}

// GetProfileEndpoint is...
func GetProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	var pI Profile
	if err := json.NewDecoder(req.Body).Decode(&pI); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
	}
	fmt.Println(pI)
	pid := pI.ID
	var profile Profile
	collection := client.Database("YOUphoria").Collection("profiles")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := collection.FindOne(ctx, bson.M{"id": pid}).Decode(&profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
	}
	json.NewEncoder(res).Encode(profile)
}

// UpdateProfileEndpoint is...
func UpdateProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "applications/json")
	var profile Profile
	json.NewDecoder(req.Body).Decode(&profile)
	pid := profile.ID
	collection := client.Database("YOUphoria").Collection("profiles")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	result, err := collection.ReplaceOne(ctx, bson.M{"id": pid}, profile)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
	}
	json.NewEncoder(res).Encode(result)
}

// DeleteProfileEndpoint is...
func DeleteProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "applications/json")
	var profile Profile
	json.NewDecoder(req.Body).Decode(&profile)
	pid := profile.ID
	collection := client.Database("YOUphoria").Collection("profiles")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	result, err := collection.DeleteOne(ctx, bson.M{"id": pid})
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
	}
	json.NewEncoder(res).Encode(result)
}
