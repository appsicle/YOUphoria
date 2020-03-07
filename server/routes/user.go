package routes

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	Mongodb "../mongodb"
	log "github.com/sirupsen/logrus"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func UserHandler(w http.ResponseWriter, r *http.Request){
	fmt.Fprintf(w, "User")
}

// Mood is...
type Mood struct {
	Mood	int		`json:"mood"`
	Time 	string	`json:"time"`
}

// Day is...
type Day struct {
	Moods	[]Mood	`json:"moods"`
	Date 	string	`json:"date"`
}

// Preference is...
type Preference struct {
	Tag		string	`json:"tag"`
	Weight	int		`json:"weight"`
}

// Profile is...
type Profile struct {
	ID         	primitive.ObjectID `json:"id"`
	UserName  	string             `json:"user"`
	Password  	string			   `json:"password"`
	Email     	string             `json:"email"`
	FullName  	string             `json:"name"`
	Preferences []Preference 	   `json:"preferences"`
	Calendar  	[]Day			   `json:"calendar"`
	CreatedOn 	string             `json:"createdOn"`
}

/* ex:
{
    "id": "5e6385f92f7aec6c1af0b1b4",
    "user": "user1",
    "password": "1234567890",
    "email": "email@yahoo.com",
    "name": "Tommy Winston",
    "preferences": [
        {
            "tag": "bowling",
            "weight": 1
        },
        {
            "tag": "rowing",
            "weight": 4
        }
    ],
    "calendar": [
		{date: "098654", moods: [
			{mood: 3, time: "0987"}, 
			{mood: 3, time: "0987"}, 
			{mood: 3, time: "0987"}
			]
		},
		{date: "098654", moods: [
			{mood: 3, time: "0987"}, 
			{mood: 3, time: "0987"}, 
			{mood: 3, time: "0987"}
			]
		},
	],
    "createdOn": "2020-03-07 03:31:05.1134445 -0800 PST m=+169.901537401"
}
*/

// Pid is...
type Pid struct {
	ID        primitive.ObjectID `json:"id"`
}

// CreateProfileEndpoint is...
func CreateProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var profile Profile
	profile.ID = primitive.NewObjectID()
	profile.CreatedOn = time.Now().String()
	if err := json.NewDecoder(req.Body).Decode(&profile)	; err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}

	log.WithFields(log.Fields{"req": profile,}).Info("CreateProfileEndpoint")

	if _, err := Mongodb.ProfileCollection.InsertOne(ctx, profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	json.NewEncoder(res).Encode(profile)
}

// GetProfileEndpoint is...
func GetProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var pid Pid
	if err := json.NewDecoder(req.Body).Decode(&pid); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}

	log.WithFields(log.Fields{"req": pid,}).Info("GetProfileEndpoint")

	var profile Profile
	if err := Mongodb.ProfileCollection.FindOne(ctx, bson.M{"id": pid.ID}).Decode(&profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	json.NewEncoder(res).Encode(profile)
}

// UpdateProfileEndpoint is...
func UpdateProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "applications/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var profile Profile
	if err := json.NewDecoder(req.Body).Decode(&profile); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}

	log.WithFields(log.Fields{"req": profile,}).Info("UpdateProfileEndpoint")

	result, err := Mongodb.ProfileCollection.ReplaceOne(ctx, bson.M{"id": profile.ID}, profile)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	json.NewEncoder(res).Encode(result)
}

// DeleteProfileEndpoint is...
func DeleteProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "applications/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var pid Pid
	if err := json.NewDecoder(req.Body).Decode(&pid); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
	}

	log.WithFields(log.Fields{"req": pid,}).Info("DeleteProfileEndpoint")

	result, err := Mongodb.ProfileCollection.DeleteOne(ctx, bson.M{"id": pid.ID})
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	json.NewEncoder(res).Encode(result)
}
