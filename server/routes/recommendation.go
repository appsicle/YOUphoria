package routes

import (
	"fmt"
	"context"
	"net/http"
	"net/url"
	"time"
	"encoding/json"
	"os"
	"math"
	"strconv"
	"sort"

	log "github.com/sirupsen/logrus"
	Mongodb "../mongodb"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Preferences is...
type Preferences struct {
	Preferences []Preference	`json:"preferences"`
}

// Preference is...
type Preference struct {
	Tag		string	`json:"tag"`
	Weight	string	`json:"weight"`
}

func (p Preference) String() string {
    return fmt.Sprintf(`'Tag': '%s', 'Weight': '%s'`, p.Tag, p.Weight)
}

func getYelpResults(yelpreq *YelpReq) (map[string]interface{}, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	reqMap := make(map[string]interface{})
	j, _ := json.Marshal(yelpreq); json.Unmarshal(j, &reqMap)	// struct -> json -> map
	queryTerms := url.Values{}
	for key, val := range reqMap {	
		queryTerms.Add(key, fmt.Sprintf("%v", val))
	}
	query := QueryStem + queryTerms.Encode()
	yelpReq, err := http.NewRequestWithContext(ctx, "GET", query, nil)
	if err != nil { return nil, err }

	yelpReq.Header.Set("content-type", "application/json")
	yelpReq.Header.Set("authorization", os.Getenv("YELPTOKEN"))

	client := &http.Client{}
	yelpRes, err := client.Do(yelpReq)
	if err != nil { return nil, err }
	if err := json.NewDecoder(yelpRes.Body).Decode(&reqMap); err != nil { return nil, err }
	
	log.WithFields(log.Fields{"res": reqMap}).Info("GetYelpResults: it's working")
	return reqMap, nil
}


// func processUserInfo(profile SafeProfile) YelpReq {
// 	wmax := math.MinInt32
// 	var tag string
// 	for preference := range profile.Preferences {
// 		if preference.Weight > wmax {
// 			wmax = preference.Weight
// 			tag = preference.Tag
// 		}
// 	}

// 	var yelpReq YelpReq
// 	yelpReq.Term = tag
// 	yelpReq.Location = 

// 	return yelpReq
// }

// func getProfileFromToken(reqMap map[string]interface{}, ctx Context) (SafeProfile, error) {
// 	id, _ := primitive.ObjectIDFromHex(reqMap["id"].(string))
// 	var profile SafeProfile
// 	if err := Mongodb.ProfileCollection.FindOne(ctx, bson.M{"id":id}).Decode(&profile); err != nil {
// 		return profile, err
// 	}
// 	return profile, nil
// }

func buildYelpReq(profile SafeProfile, reqMap map[string]interface{}) YelpReq {
	wmax := math.MinInt32
	var tag string
	var yr YelpReq

	for _, pref := range profile.Preferences {
		weight, _ := strconv.Atoi(pref.Weight)
		if weight > wmax {
			wmax = weight
			tag = pref.Tag
		}
	}

	yr.Category = tag
	yr.Latitude = fmt.Sprintf("%v", reqMap["latitude"])
	yr.Longitude = fmt.Sprintf("%v", reqMap["longitude"])
	yr.Radius = 20000
	yr.Limit = 1

	return yr
}

func GetRecommendationEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}

	log.WithFields(log.Fields{"req body": reqMap,}).Info("GetRecommendationEndpoint: incoming request")

	// profile, err := getProfileFromToken(reqMap, ctx)
	// if err != nil {
	// 	res.WriteHeader(http.StatusInternalServerError)
	// 	res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
	// }
	id, _ := primitive.ObjectIDFromHex(reqMap["id"].(string))
	var profile SafeProfile
	if err := Mongodb.ProfileCollection.FindOne(ctx, bson.M{"id":id}).Decode(&profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	yelpReq := buildYelpReq(profile, reqMap)
	yelpRes, err := getYelpResults(&yelpReq)
	if err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	json.NewEncoder(res).Encode(yelpRes)
}

// SendUserInterestsEndpoint is...
func SendUserInterestsEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("SendUserInterestsEndpoint: incoming request")

	// create preferences
	preferences := []Preference{}
	for _, interest := range reqMap["interests"].([]interface{}){
		preference := Preference{interest.(string), "3"}
		preferences = append(preferences, preference)
	}

	// add preferences
	filter := bson.M{ "id" : Mongodb.StoOI(reqMap["id"].(string))}
	update := bson.M{ "$push" : bson.M{"preferences": bson.M{ "$each": preferences}}}
	if _, err := Mongodb.ProfileCollection.UpdateOne(ctx, filter, update); err != nil{
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	
	log.WithFields(log.Fields{}).Info("SendUserInterestsEndpoint: outgoing result")
}

// GetUserInterestsEndpoint is...
func GetUserInterestsEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("GetUserInterestsEndpoint: incoming request")

	// get preferences
	preferences := Preferences{}
	filter := bson.M{"id": Mongodb.StoOI(reqMap["id"].(string))}
	if err := Mongodb.ProfileCollection.FindOne(ctx, filter).Decode(&preferences); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// sort by weight (desc)
	sort.Slice(preferences.Preferences, func(i, j int) bool {
		a, _ := strconv.Atoi(preferences.Preferences[i].Weight)
		b, _ := strconv.Atoi(preferences.Preferences[j].Weight)
		return a > b
	})

	log.WithFields(log.Fields{"res": preferences}).Info("GetUserInterestsEndpoint: outgoing result")
	json.NewEncoder(res).Encode(preferences)
}

// AddRecommendationFeedbackEndpoint is...
func AddRecommendationFeedbackEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("AddRecommendationFeedbackEndpoint: incoming request")


	// get preferences
	preferences := Preferences{}
	filter := bson.M{"id": Mongodb.StoOI(reqMap["id"].(string))}
	if err := Mongodb.ProfileCollection.FindOne(ctx, filter).Decode(&preferences); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// filter for pref 
	preference := Preference{}
	for _, pref := range preferences.Preferences {
		if pref.Tag == reqMap["tag"] {
			preference = pref
		}
	}

	// update preference
	newWeight := strconv.Itoa(atoi(preference.Weight) + adjustment(atoi(reqMap["liked"].(string))))
	filter = bson.M{ "id" : Mongodb.StoOI(reqMap["id"].(string)),
					  "preferences.tag" : reqMap["tag"].(string)}
	update := bson.M{ "$set": bson.M{ "preferences.$.weight" : newWeight}}
	if _, err := Mongodb.ProfileCollection.UpdateOne(ctx, filter, update); err != nil{
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	
	log.WithFields(log.Fields{}).Info("AddRecommendationFeedbackEndpoint: outgoing result")
}

func adjustment(selector int) (int){
	if selector == 1{
		return 1
	}
	if selector == 0{
		return -1
	}
	return 0
}

func atoi(s string)(int){
	i , _ := strconv.Atoi(s)
	return i
}