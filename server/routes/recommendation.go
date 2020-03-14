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
	
	log "github.com/sirupsen/logrus"
	Mongodb "../mongodb"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)


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
