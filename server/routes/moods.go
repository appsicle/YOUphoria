package routes

// import (
// 	"context"
// 	"encoding/json"
// 	"net/http"
// 	"time"
// 	"strings"

// 	Mongodb "../mongodb"
// 	log "github.com/sirupsen/logrus"
// 	// "github.com/google/uuid"
// 	"github.com/mitchellh/mapstructure"

// 	"go.mongodb.org/mongo-driver/bson"
// 	"go.mongodb.org/mongo-driver/bson/primitive"
// )

// Mood is...
type Mood struct {
	Mood	int		`json:"mood"`
	Date 	string	`json:"date"`
	Time 	string	`json:"time"`
}

// Calendar is...
type Calendar struct {
	Calendar []Mood	`json:"calendar"`
}

// // AddMoodEndpoint is...
// func AddMoodEndpoint(res http.ResponseWriter, req *http.Request) {
// 	res.Header().Set("content-type", "application/json")
// 	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
// 	defer cancel()

// 	// get token
// 	reqAuthHeader := req.Header.Get("Authorization")
// 	reqToken := strings.Split(reqAuthHeader, "Bearer ")[1]

// 	// map req body
// 	reqMap := make(map[string]interface{})
// 	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
// 		http.Error(res, err.Error(), http.StatusBadRequest)
// 		return
// 	}
// 	log.WithFields(log.Fields{"req body": reqMap,}).Info("AddMoodEndpoint: incoming request")


// 	var mood Mood
// 	mood.Mood = reqMap["mood"].(int)
// 	mood.Date = reqMap["date"].(string)
// 	mood.Time = reqMap["time"].(string)





// 	filter := bson.M{ "id" :  }


// 	if _, err := Mongodb.TokenCollection.InsertOne(ctx, mood); err != nil{
// 		res.WriteHeader(http.StatusInternalServerError)
// 		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
// 		return
// 	}
	

// 	// if interest, add 1 to weight of user
	

// 	if _, err := Mongodb.TokenCollection.InsertOne(ctx, token); err != nil{
// 		res.WriteHeader(http.StatusInternalServerError)
// 		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
// 		return
// 	}

// 	// map res
// 	resMap := make(map[string]interface{})
// 	resMap["token"] = token.Token
// 	log.WithFields(log.Fields{"res": resMap,}).Info("AddMoodEndpoint: outgoing result")
// 	json.NewEncoder(res).Encode(resMap)
// }
