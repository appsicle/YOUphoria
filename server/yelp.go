package main

import (
	"fmt"
	"context"
	"encoding/json"
	"net/http"
	"net/url"
	"time"
	"os"

	log "github.com/sirupsen/logrus"
)

// YelpReq is...
type YelpReq struct {
	// Term 	  string		`json:"term"`				// mandatory
	Categories string 		`json:"categories"`
	Location   string		`json:"location,omitempty"`
	Latitude   string		`json:"latitude"`
	Longitude  string 		`json:"longitude"`
	Radius 	   int			`json:"radius,omitempty"`		// max = 40000 ~25 miles
	Limit	   int			`jons:"limit,omitempty"`		// default = 20, max = 50
	SortBy	   string		`json:"sort_by,omitempty"`		// rating, distance, review_count, default = best_match
	StartDate  int32 		`json:"start_date,omitempty"`	// unix timestamp
}

// ex: https://api.yelp.com/v3/businesses/search?term=taco%20truck&location=irvine&sort_by=rating&radius=20000

var QueryStem = "https://api.yelp.com/v3/events?"


func GetYelpResults(res http.ResponseWriter, req *http.Request){
	res.Header().Set("content-type", "application/json")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// map req body
	reqMap := make(map[string]interface{})
	if err := json.NewDecoder(req.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}
	log.WithFields(log.Fields{"req": reqMap,}).Info("YelpHandler: incoming request")

	queryTerms := url.Values{}
	for key, val := range reqMap {
		queryTerms.Add(key, fmt.Sprintf("%v", val))
	}
	query := QueryStem + queryTerms.Encode()
	yelpReq, err := http.NewRequestWithContext(ctx, "GET", query, nil)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	yelpReq.Header.Set("content-type", "application/json")
	yelpReq.Header.Set("authorization", os.Getenv("YELPTOKEN"))

	client := &http.Client{}
	yelpRes, err := client.Do(yelpReq)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	if err := json.NewDecoder(yelpRes.Body).Decode(&reqMap); err != nil {
		http.Error(res, err.Error(), http.StatusBadRequest)
		return
	}

	log.WithFields(log.Fields{"res":"its working"}).Info("GetYelpResults: it's working")
	json.NewEncoder(res).Encode(reqMap)
}
