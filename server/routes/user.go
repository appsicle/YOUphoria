package routes

import (
	"context"
	"encoding/json"
	"net/http"
	"time"
	"strings"

	Mongodb "../mongodb"
	log "github.com/sirupsen/logrus"
	"github.com/google/uuid"
	"github.com/mitchellh/mapstructure"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

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
	UserName  	string             `json:"username" mapstructure:"username"`
	Password  	string			   `json:"password,omitempty"`
	Email     	string             `json:"email" mapstructure:"email"`
	FullName  	string             `json:"name" mapstructure:"name"`
	Preferences []Preference 	   `json:"preferences" mapstructure:"preferences"`
	Calendar  	[]Day			   `json:"calendar"`
	CreatedOn 	string             `json:"createdOn"`
}

/* ex:
{
    "id": "5e6385f92f7aec6c1af0b1b4",
    "username": "user1",
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
		{"date": "098654", "moods": [
			{"mood": 3, "time": "0987"}, 
			{"mood": 3, "time": "0987"}, 
			{"mood": 3, "time": "0987"}
			]
		},
		{"date": "098654", "moods": [
			{"mood": 3, "time": "0987"}, 
			{"mood": 3, "time": "0987"}, 
			{"mood": 3, "time": "0987"}
			]
		}
	],
    "createdOn": "2020-03-07 03:31:05.1134445 -0800 PST m=+169.901537401"
}
*/

// Token is...
type Token struct {
	Token	string     		   `json:"token"`
	PID		primitive.ObjectID `json:"pid"`
}

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

	// dup username or email
	filter := bson.M{ "$or": []interface{}{
		bson.M{"username": reqMap["username"]}, 
		bson.M{"email": reqMap["email"]}}}
	cursor, err := Mongodb.ProfileCollection.Find(ctx, filter)
	if err != nil {
		http.Error(res, `{"message":"` + err.Error() + `"}`, http.StatusInternalServerError); return
	}l
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
	if _, err := Mongodb.ProfileCollection.InsertOne(ctx, profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// create token
	var token Token
	token.PID = profile.ID
	token.Token = uuid.New().String()
	if _, err := Mongodb.TokenCollection.InsertOne(ctx, token); err != nil{
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

	// get token
	reqAuthHeader := req.Header.Get("Authorization")
	reqToken := strings.Split(reqAuthHeader, "Bearer ")[1]

	log.WithFields(log.Fields{"req token": reqToken,}).Info("CreateProfileEndpoint: incoming request")

	// get PID by token
	var token Token
	token.Token = reqToken
	if err := Mongodb.TokenCollection.FindOne(ctx, bson.M{"token": token.Token}).Decode(&token); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// get Profile
	var profile Profile
	if err := Mongodb.ProfileCollection.FindOne(ctx, bson.M{"id": token.PID}).Decode(&profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	profile.Password = ""	// TODO projection

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
	if err := Mongodb.ProfileCollection.FindOne(ctx, filter).Decode(&profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// create token
	var token Token
	token.PID = profile.ID
	token.Token = uuid.New().String()
	if _, err := Mongodb.TokenCollection.InsertOne(ctx, token); err != nil{
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

	// get token
	reqAuthHeader := req.Header.Get("Authorization")
	reqToken := strings.Split(reqAuthHeader, "Bearer ")[1]
	log.WithFields(log.Fields{"req token": reqToken,}).Info("LogoutProfileEndpoint: incoming request")

	// delete token
	_, err := Mongodb.TokenCollection.DeleteOne(ctx, bson.M{"token": reqToken})
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

	// get token
	reqAuthHeader := req.Header.Get("Authorization")
	reqToken := strings.Split(reqAuthHeader, "Bearer ")[1]

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req token": reqToken, "req body": reqMap,}).Info("UpdateProfileEndpoint: incoming request")

	// get PID by token
	var token Token
	token.Token = reqToken
	if err := Mongodb.TokenCollection.FindOne(ctx, bson.M{"token": token.Token}).Decode(&token); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// update profile
	filter := bson.M{"id": bson.M{"$eq": token.PID,},}
	update := bson.M{"$set": bson.M{reqMap["attribute"].(string): reqMap["value"].(string)}}
	_, err := Mongodb.ProfileCollection.UpdateOne(ctx, filter, update)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	log.WithFields(log.Fields{}).Info("UpdateProfileEndpoint: outgoing result")
}

// DeleteProfileEndpoint is...
func DeleteProfileEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "applications/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// get token
	reqAuthHeader := req.Header.Get("Authorization")
	reqToken := strings.Split(reqAuthHeader, "Bearer ")[1]

	log.WithFields(log.Fields{"req token": reqToken,}).Info("DeleteProfileEndpoint: incoming request")

	// get PID by token
	var token Token
	token.Token = reqToken
	if err := Mongodb.TokenCollection.FindOne(ctx, bson.M{"token": token.Token}).Decode(&token); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// delete token
	_, err := Mongodb.TokenCollection.DeleteOne(ctx, bson.M{"token": reqToken})
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// delete profile
	_, err = Mongodb.ProfileCollection.DeleteOne(ctx, bson.M{"id": token.PID})
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	log.WithFields(log.Fields{}).Info("DeleteProfileEndpoint: outgoing result")
}
