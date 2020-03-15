package main

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

func getYelpResults(yelpreq *YelpReq) (interface{}, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	reqMap := make(map[string]interface{})
	j, _ := json.Marshal(yelpreq); json.Unmarshal(j, &reqMap)	// struct -> json -> map
	fmt.Println(reqMap)
	reqMap["start_date"] = int(reqMap["start_date"].(float64))
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

	resMap := make(map[string]interface{})
	if err := json.NewDecoder(yelpRes.Body).Decode(&resMap); err != nil { return nil, err }
	
	log.WithFields(log.Fields{"res": resMap}).Info("GetYelpResults: it's working")
	return resMap["events"].([]interface{})[0], nil
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

	yr.Categories = tag
	yr.Latitude = fmt.Sprintf("%v", reqMap["latitude"])
	yr.Longitude = fmt.Sprintf("%v", reqMap["longitude"])
	yr.Radius = 40000
	yr.Limit = 1
	yr.StartDate = int32(time.Now().Unix())

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
	if err := ProfileCollection.FindOne(ctx, bson.M{"id":id}).Decode(&profile); err != nil {
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
	filter := bson.M{ "id" : StoOI(reqMap["id"].(string))}
	update := bson.M{ "$push" : bson.M{"preferences": bson.M{ "$each": preferences}}}
	if _, err := ProfileCollection.UpdateOne(ctx, filter, update); err != nil{
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
	filter := bson.M{"id": StoOI(reqMap["id"].(string))}
	if err := ProfileCollection.FindOne(ctx, filter).Decode(&preferences); err != nil {
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

// SendFeedbackEndpoint is...
func SendFeedbackEndpoint(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req body": reqMap,}).Info("SendFeedbackEndpoint: incoming request")

	// get preferences
	preferences := Preferences{}
	filter := bson.M{"id": StoOI(reqMap["id"].(string))}
	if err := ProfileCollection.FindOne(ctx, filter).Decode(&preferences); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}	

	// insert tag if not in personal preference
	found := false
	for _, tag := range reqMap["tags"].([]interface{}){
		found = false
		for _, pref := range preferences.Preferences {
			if pref.Tag == tag.(string) {
				found = true
				break
			}
		}
		
		if !found {
			// add preference
			p := Preference{tag.(string), "10"}
			filter := bson.M{ "id" : StoOI(reqMap["id"].(string))}
			update := bson.M{ "$push" : bson.M{"preferences": p}}
			if _, err := ProfileCollection.UpdateOne(ctx, filter, update); err != nil{
				res.WriteHeader(http.StatusInternalServerError)
				res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
				return
			}
			preferences.Preferences = append(preferences.Preferences, p)
		}
	}	

	// // filter for prefs 
	// preferences := Preferences{}
	// n := 0
	// for _, pref := range preferences_pre.Preferences {
	// 	if pref.Tag == reqMap["tag"] {
	// 		preferences.Preferences = append(preferences.Preferences, pref)
	// 		n++
	// 	}
	// }
	// preferences.Preferences = preferences.Preferences[:n]	

	// update personal preferences weight
	for _, tag := range reqMap["tags"].([]interface{}){
		for i, pref := range preferences.Preferences {
			if pref.Tag == tag.(string) {
				preferences.Preferences[i].Weight = strconv.Itoa(atoi(pref.Weight) + adjustment(atoi(reqMap["liked"].(string))))
				break
			}
		}
	}	

	// // TODO update CF weights



	// update preferences
	filter = bson.M{ "id" : StoOI(reqMap["id"].(string))}
	update := bson.M{ "$set": bson.M{ "preferences" : preferences.Preferences}}
	if _, err := ProfileCollection.UpdateOne(ctx, filter, update); err != nil{
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	
	log.WithFields(log.Fields{}).Info("SendFeedbackEndpoint: outgoing result")
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