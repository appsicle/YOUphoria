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
	"math/rand"
	"strconv"
	"sort"

	log "github.com/sirupsen/logrus"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Preference is...
type Preference struct {
	Tag		string	`json:"tag"`
	Weight	string	`json:"weight"`
}

// Preferences is...
type Preferences struct {
	Preferences []Preference	`json:"preferences"`
}

// ZipCode is...
type ZipCode struct {
	ZipCode		string 	`json:"zipcode"`
	Weight		string 	`json:"weight"`
}

// ZipCodes is...
type ZipCodes struct {
	Zips []ZipCode	`json:"zipcodes"`
}

// Gender is...
type Gender struct {
	Gender 	string 	`json:"gender"`
	Weight	string 	`json:"weight"`
}

// Genders is...
type Genders struct {
	Genders []Gender `json:"genders"`
}

// AgeRange is...
type AgeRange struct {
	Range 	string 	`json:"range"`	// 1, 2, 3, 4, 5, 6, 7, ...
	Weight 	string 	`json:"weight"`
}

// AgeRanges is...
type AgeRanges struct {
	AgeRanges []AgeRange	`json:"ageranges"`
}

// CategoryDoc is...
type CategoryDoc struct {
	Category	string 		`json:"category"`
	ZipCodes 	[]ZipCode	`json:"zipcodes"`
	Genders		[]Gender	`json:"genders"`
	AgeRanges	[]AgeRange	`json:"ageranges"`
}

/* ex:
{
	"id": "fsdjkfhdslkfjsdbcsdejf",
	"category": "music",
	"genders": [
		{
			"gender": "male",
			"weight": "10"
		},
		{
			"gender": "female",
			"weight": "10",
		},
		{
			"gender": "other",
			"weight": "10",
		}
	],
	"zipcodes": [

	],
	"ageranges": [
		{
			"range": "0",
			"weight": "10",
		},
		{
			"range": "1",
			"weight": "10",
		},
		{
			"range": "2",
			"weight": "10",
		},
		{
			"range": "3",
			"weight": "10",
		},
		{
			"range": "4",
			"weight": "10",
		},
	],
}
*/

func (p Preference) String() string {
    return fmt.Sprintf(`'Tag': '%s', 'Weight': '%s'`, p.Tag, p.Weight)
}

func cfGetGenderWeight(tag string, gender string, ctx *context.Context) (int, error) {
	log.Info("Entering cfGetGenderWeight...", tag, gender)
	var categoryDoc CategoryDoc
	var result int = 0
	if err := CategoryCollection.FindOne(*ctx, bson.M{"category": tag}).Decode(&categoryDoc); err != nil {
		log.Info("Exiting cfGetGenderWeight with error...")
		return 0, err
	}
	for _, sGender := range categoryDoc.Genders {
		if sGender.Gender == gender {
			result, _ = strconv.Atoi(sGender.Weight)
		}	
	}
	log.Info("Exiting cfGetGenderWeight...")
	return result, nil
}

func cfGetAgeRangeWeight(tag string, agerange string, ctx *context.Context) (int, error) {
	log.Info("Entering cfGetAgeRangeWeight...")
	var categoryDoc CategoryDoc
	var result int = 0
	if err := CategoryCollection.FindOne(*ctx, bson.M{"category": tag}).Decode(&categoryDoc); err != nil {
		log.Info("Exiting cfGetAgeRangeWeight with error...")
		return 0, err
	}
	for _, sAge := range categoryDoc.AgeRanges {
		if sAge.Range == ageGroup(agerange) {
			result, _ = strconv.Atoi(sAge.Weight)
		}	
	}
	log.Info("Exiting cfGetAgeRangeWeight...")
	return result, nil
}

func cfGetZipcodeRangeWeight(tag string, zipcode string, ctx *context.Context) (int, error) {
	log.Info("Entering ZipcodeRangeWeight...")
	var categoryDoc CategoryDoc
	var result int = 0
	if err := CategoryCollection.FindOne(*ctx, bson.M{"category": tag}).Decode(&categoryDoc); err != nil {
		log.Info("Exiting cfGetZipcodeRangeWeight with error...")
		return 0, err
	}

	for _, sZip := range categoryDoc.ZipCodes {
		if sZip.ZipCode == zipCodeGroup(zipcode) {
			result, _ = strconv.Atoi(sZip.Weight)
		}	
	}
	log.Info("Exiting ZipcodeRangeWeight...")
	return result, nil
}

func getTopCategory(profile *SafeProfile, ctx *context.Context) (string, error) {
	log.Info("Entering getTopCategory...", *profile)
	var tag string
	wmax := math.SmallestNonzeroFloat64
	for _, pref := range profile.Preferences {
		weight, _ := strconv.Atoi(pref.Weight)

		gWeight, wErr := cfGetGenderWeight(pref.Tag, profile.Gender, ctx)
		if wErr != nil { return "", wErr }
		arWeight, arErr := cfGetAgeRangeWeight(pref.Tag, profile.Age, ctx)
		if arErr != nil { return "", arErr}
		zWeight, zErr := cfGetZipcodeRangeWeight(pref.Tag, profile.ZipCode, ctx)
		if zErr != nil { return "", zErr}
		
		total := float64(weight) + (float64(gWeight) * 0.9) + (float64(arWeight) * 0.5) + (float64(zWeight) * 0.6)
		// fmt.Println(total, " ", )
		if wmax == math.SmallestNonzeroFloat64 || (profile.LastRecommended != pref.Tag && total > wmax) {
			wmax = total
			tag = pref.Tag
		}
	}

	log.Info("Exiting getTopCategory...")
	return tag, nil
}

func updateLastRecommendedCategory(profile *SafeProfile, ctx *context.Context, category string) (error){
	// update last recommended
	filter := bson.M{ "username" : profile.UserName}
	update := bson.M{ "$set": bson.M{ "lastRecommended" : category}}
	if _, err := ProfileCollection.UpdateOne(*ctx, filter, update); err != nil{
		return err
	}
	return nil
}

func buildYelpReq(profile SafeProfile, reqMap map[string]interface{}, ctx *context.Context) (YelpReq, error) {
	var yr YelpReq

	category, err := getTopCategory(&profile, ctx)
	if err != nil {
		return yr, err
	}

	if err = updateLastRecommendedCategory(&profile, ctx, category); err != nil {
		return yr, err
	}
	yr.Categories = category
	yr.Latitude = fmt.Sprintf("%v", reqMap["latitude"])
	yr.Longitude = fmt.Sprintf("%v", reqMap["longitude"])
	yr.Radius = 40000
	yr.Limit = 10	
	yr.StartDate = int32(time.Now().Unix())

	return yr, nil
}

func getYelpResults(yelpreq *YelpReq, ctx *context.Context) (interface{}, error) {
	reqMap := make(map[string]interface{})
	j, _ := json.Marshal(yelpreq); json.Unmarshal(j, &reqMap)	// struct -> json -> map
	reqMap["start_date"] = int(reqMap["start_date"].(float64))
	queryTerms := url.Values{}
	for key, val := range reqMap {	
		queryTerms.Add(key, fmt.Sprintf("%v", val))
	}
	query := QueryStem + queryTerms.Encode()
	yelpReq, err := http.NewRequestWithContext(*ctx, "GET", query, nil)
	if err != nil { return nil, err }

	yelpReq.Header.Set("content-type", "application/json")
	yelpReq.Header.Set("authorization", os.Getenv("YELPTOKEN"))

	client := &http.Client{}
	yelpRes, err := client.Do(yelpReq)
	if err != nil { return nil, err }

	resMap := make(map[string]interface{})
	if err := json.NewDecoder(yelpRes.Body).Decode(&resMap); err != nil { return nil, err }

	// randomizer
	event := resMap["events"].([]interface{})[rand.Intn(int(resMap["total"].(float64)))]

	log.WithFields(log.Fields{"results total": resMap["total"].(float64)}).Info()
	log.WithFields(log.Fields{"res": resMap}).Info("GetYelpResults: it's working")
	return event, nil
}

// GetRecommendationEndpoint is...
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

	id, _ := primitive.ObjectIDFromHex(reqMap["id"].(string))
	var profile SafeProfile
	if err := ProfileCollection.FindOne(ctx, bson.M{"id":id}).Decode(&profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	yelpReq, err := buildYelpReq(profile, reqMap, &ctx)
	if err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	yelpRes, err := getYelpResults(&yelpReq, &ctx)
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

	// update personal preferences weight
	for _, tag := range reqMap["tags"].([]interface{}){
		for i, pref := range preferences.Preferences {
			if pref.Tag == tag.(string) {
				preferences.Preferences[i].Weight = strconv.Itoa(atoi(pref.Weight) + adjustment(atoi(reqMap["liked"].(string))))
				break
			}
		}
	}	

	// update preferences
	filter = bson.M{ "id" : StoOI(reqMap["id"].(string))}
	update := bson.M{ "$set": bson.M{ "preferences" : preferences.Preferences}}
	if _, err := ProfileCollection.UpdateOne(ctx, filter, update); err != nil{
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}

	// get profile
	profile := Profile{}
	filter = bson.M{"id": StoOI(reqMap["id"].(string))}
	if err := ProfileCollection.FindOne(ctx, filter).Decode(&profile); err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}	

	// update CF categories weights
	for _, tag := range reqMap["tags"].([]interface{}) {

		// get categories
		categoryDoc := CategoryDoc{}
		filter = bson.M{"category": tag.(string)}
		if err := CategoryCollection.FindOne(ctx, filter).Decode(&categoryDoc); err != nil {
			res.WriteHeader(http.StatusInternalServerError)
			res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
			return
		}

		// modify categories weights
		for i, g := range categoryDoc.Genders{
			if g.Gender == profile.Gender{
				categoryDoc.Genders[i].Weight = strconv.Itoa(atoi(g.Weight) + adjustment(atoi(reqMap["liked"].(string))))
				break
			}
		}
		for i, a := range categoryDoc.AgeRanges{
			if a.Range == ageGroup(profile.Age){
				categoryDoc.AgeRanges[i].Weight = strconv.Itoa(atoi(a.Weight) + adjustment(atoi(reqMap["liked"].(string))))
				break
			}
		}
		for i, z := range categoryDoc.ZipCodes{
			if z.ZipCode == zipCodeGroup(profile.ZipCode){
				categoryDoc.ZipCodes[i].Weight = strconv.Itoa(atoi(z.Weight) + adjustment(atoi(reqMap["liked"].(string))))
				break
			}
		}

		// update categories
		filter = bson.M{"category": tag.(string)}
		update := bson.M{ "$set": bson.M{ "genders" : categoryDoc.Genders, 
											"ageranges" : categoryDoc.AgeRanges, 
											"zipcodes" : categoryDoc.ZipCodes }}
		if _, err := CategoryCollection.UpdateOne(ctx, filter, update); err != nil{
			res.WriteHeader(http.StatusInternalServerError)
			res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
			return
		}
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

func ageGroup(s string) (string){
	i := atoi(s)
	if i < 18 { return "0" }
	if i < 30 { return "1" }
	if i < 50 { return "2" }
	if i < 70 {	return "3" }
	return "4"
}

func zipCodeGroup(s string) (string){
	i := atoi(s)
	if i < 10000 { return "0" }
	if i < 20000 { return "1" }
	if i < 30000 { return "2" }
	if i < 40000 { return "3" }
	if i < 50000 { return "4" }
	if i < 60000 { return "5" }
	if i < 70000 { return "6" }
	if i < 80000 { return "7" }
	if i < 90000 { return "8" }
	return "9"
}
