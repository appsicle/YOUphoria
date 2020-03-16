package main

import (
	"context"
	"encoding/json"
	"net/http"
	"time"
	"strings"
	"strconv"

	log "github.com/sirupsen/logrus"
	"github.com/google/uuid"
	"github.com/mitchellh/mapstructure"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Profile is...
type Profile struct {
	ID         	primitive.ObjectID `json:"id"` 
	UserName  	string             `json:"username" mapstructure:"username"`
	Password  	string			   `json:"password,omitempty"`
	Gender		string			   `json:"gender"`
	Age		    string			   `json:"age"`
	BirthDate	string			   `json:"birthDate"`
	ZipCode		string			   `json:"zipcode"`
	Preferences []Preference 	   `json:"preferences" mapstructure:"preferences"`
	Calendar  	[]Mood			   `json:"calendar"`
	CreatedOn 	string             `json:"createdOn"`
}

// SafeProfile is...
type SafeProfile struct {
	UserName  	string             `json:"username" mapstructure:"username"`
	Gender		string			   `json:"gender"`
	Age		    string			   `json:"age"`
	BirthDate	string			   `json:"birthDate"`
	ZipCode		string			   `json:"zipcode"`
	Preferences []Preference 	   `json:"preferences" mapstructure:"preferences"`
	Calendar  	[]Mood			   `json:"calendar"`
}

/* ex:
{
    "id": "5e6385f92f7aec6c1af0b1b4",
    "username": "user1",
    "password": "1234567890",
    "preferences": [
        { "tag": "bowling", "weight": "1" },
        { "tag": "rowing", "weight": "4" }
    ],
    "calendar": [
		{"mood": 0, "date": "1/2/13", "time": "02:32"},
		{"mood": 3, "date": "1/3/13", "time": "02:32"},
		{"mood": 3, "date": "1/4/13", "time": "02:32"},
		{"mood": 5, "date": "1/5/13", "time": "02:32"},
	],
    "createdOn": "2020-03-07 03:31:05.1134445 -0800 PST m=+169.901537401"
}
*/

// CreateProfileEndpoint is...
func CreateProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("CreateProfileEndpoint: incoming request")

	// dup username
	filter := bson.M{"username": reqMap["username"]}
	cursor, err := ProfileCollection.Find(ctx, filter)
	if err != nil {
		http.Error(res, `{"message":"` + err.Error() + `"}`, http.StatusInternalServerError); return
	}
	if cursor.Next(ctx){
		http.Error(res, `{"error":"Duplicate username or email"}`, http.StatusBadRequest); return
	}

	// create profile
	var profile Profile
	if err := mapstructure.Decode(reqMap, &profile); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	profile.ID = primitive.NewObjectID()
	profile.CreatedOn = time.Now().String()
	profile.Password = reqMap["password"].(string)	// TODO hash password
	profile.Calendar = []Mood{}
	profile.Preferences = []Preference{}
	if _, err := ProfileCollection.InsertOne(ctx, profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// create token
	var token Token
	token.PID = profile.ID
	token.Token = uuid.New().String()
	if _, err := TokenCollection.InsertOne(ctx, token); err != nil{
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// map res
	resMap := make(map[string]interface{})
	resMap["token"] = token.Token
	log.WithFields(log.Fields{"res": resMap,}).Info("CreateProfileEndpoint: outgoing result")
	json.NewEncoder(res).Encode(resMap)
}


// GetProfileEndpoint is...
func GetProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("GetProfileEndpoint: incoming request")

	id, _ := primitive.ObjectIDFromHex(reqMap["id"].(string))
	var profile SafeProfile
	if err := ProfileCollection.FindOne(ctx, bson.M{"id":id}).Decode(&profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	log.WithFields(log.Fields{"res": profile,}).Info("GetProfileEndpoint: outgoing result")
	json.NewEncoder(res).Encode(profile)
}

// LoginProfileEndpoint is...
func LoginProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("LoginProfileEndpoint: incoming request")

	// get Profile
	var profile Profile
	filter := bson.M{"username": reqMap["username"].(string), "password": reqMap["password"].(string)}
	if err := ProfileCollection.FindOne(ctx, filter).Decode(&profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// create token
	var token Token
	token.PID = profile.ID
	token.Token = uuid.New().String()
	if _, err := TokenCollection.InsertOne(ctx, token); err != nil{
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// map res (profile + token)
	// resMap := make(map[string]interface{})
	// j, _ := json.Marshal(profile); json.Unmarshal(j, &resMap)	// struct -> json -> map
	// resMap["token"] = token.Token

	// map token
	resMap := make(map[string]interface{})
	resMap["token"] = token.Token

	log.WithFields(log.Fields{"res": resMap,}).Info("LoginProfileEndpoint: outgoing result")
	json.NewEncoder(res).Encode(resMap)
}

// LogoutProfileEndpoint is...
func LogoutProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("LogoutProfileEndpoint: incoming request")

	// delete token
	_, err := TokenCollection.DeleteOne(ctx, bson.M{"token": reqMap["token"]})
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	log.WithFields(log.Fields{}).Info("LogoutProfileEndpoint: outgoing result")
}

// UpdateProfileEndpoint is...
func UpdateProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "applications/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("UpdateProfileEndpoint: incoming request")

	// update profile
	id, _ := primitive.ObjectIDFromHex(reqMap["id"].(string))
	filter := bson.M{"id": id,}
	update := bson.M{"$set": bson.M{reqMap["attribute"].(string): reqMap["value"].(string)}}
	_, err := ProfileCollection.UpdateOne(ctx, filter, update)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	log.WithFields(log.Fields{}).Info("UpdateProfileEndpoint: outgoing result")
}

// AddProfileDetailsEndpoint is...
func AddProfileDetailsEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "applications/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("AddProfileDetailsEndpoint: incoming request")

	// update profile
	id, _ := primitive.ObjectIDFromHex(reqMap["id"].(string))
	filter := bson.M{"id": id,}
	update := bson.M{"$set": bson.M{ "gender" : reqMap["gender"].(string), 
										"birthday": reqMap["birthday"].(string),
										"age" : determineAge(reqMap["birthday"].(string)),
										"zipcode" : reqMap["zipcode"].(string)}}
	_, err := ProfileCollection.UpdateOne(ctx, filter, update)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	log.WithFields(log.Fields{}).Info("AddProfileDetailsEndpoint: outgoing result")
}

// DeleteProfileEndpoint is...
func DeleteProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "applications/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("DeleteProfileEndpoint: incoming request")

	// delete token
	_, err := TokenCollection.DeleteOne(ctx, bson.M{"token": reqMap["token"]})
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// delete profile
	id, _ := primitive.ObjectIDFromHex(reqMap["id"].(string))
	_, err = ProfileCollection.DeleteOne(ctx, bson.M{"id": id})
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	log.WithFields(log.Fields{}).Info("DeleteProfileEndpoint: outgoing result")
}

func determineAge(birthday string) (string){
	if birthday == "" {
		return "-1"
	}
	// "1999-11-02" -> 20
	birthdaySlice := strings.Split(birthday, "-")

	birthdayDate := time.Date(atoi(birthdaySlice[0]), 
						time.Month(atoi(birthdaySlice[1])), 
						atoi(birthdaySlice[2]), 0, 0, 0, 0, time.UTC)

	diff := int(time.Now().Sub(birthdayDate).Hours())

	return strconv.Itoa(diff/8760)
}