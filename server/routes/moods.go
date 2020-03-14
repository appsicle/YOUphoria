package routes

import (
	"context"
	"encoding/json"
	"net/http"
	"time"
	"strconv"

	Mongodb "../mongodb"
	log "github.com/sirupsen/logrus"

	"go.mongodb.org/mongo-driver/bson"
)

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

// AddMoodEndpoint is...
func AddMoodEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("AddMoodEndpoint: incoming request")

	var mood Mood
	mood.Mood, _ = strconv.Atoi(reqMap["mood"].(string))
	mood.Date = reqMap["date"].(string)
	mood.Time = reqMap["time"].(string)

	filter := bson.M{ "id" : Mongodb.StoOI(reqMap["id"].(string))}
	update := bson.M{ "$push" : bson.M{"calendar": mood}}
	if _, err := Mongodb.ProfileCollection.UpdateOne(ctx, filter, update); err != nil{
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	
	log.WithFields(log.Fields{}).Info("AddMoodEndpoint: outgoing result")
}

// getAllMoodsEndpoint is...
func getAllMoodsEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("getAllMoodsEndpoint: incoming request")

	var calendar Calendar
	filter := bson.M{"id": Mongodb.StoOI(reqMap["id"].(string))}
	if err := Mongodb.ProfileCollection.FindOne(ctx, filter).Decode(&calendar); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	log.WithFields(log.Fields{"res": calendar}).Info("getAllMoodsEndpoint: outgoing result")
	json.NewEncoder(res).Encode(calendar)
}

// GetMoodForDayEndpoint is...
func GetMoodsForDayEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("GetMoodForDayEndpoint: incoming request")

	var calendar Calendar
	filter := bson.M{"id": Mongodb.StoOI(reqMap["id"].(string))}
	if err := Mongodb.ProfileCollection.FindOne(ctx, filter).Decode(&calendar); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// filter calendar (in place)
	n := 0
	for _, mood := range calendar.Calendar {
		if mood.Date == reqMap["date"] {
			calendar.Calendar[n] = mood
			n++
		}
	}
	calendar.Calendar = calendar.Calendar[:n]

	log.WithFields(log.Fields{"res": calendar}).Info("GetMoodForDayEndpoint: outgoing result")
	json.NewEncoder(res).Encode(calendar)
}