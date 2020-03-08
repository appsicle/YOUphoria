package routes

import (
	"fmt"
	"context"
	"encoding/json"
	"net/http"
	"net/url"
	"time"

	log "github.com/sirupsen/logrus"
)

// YelpReq is...
type YelpReq struct {
	Term 	 string		`json:"term"`				// mandatory
	Location string		`json:"location"`			// mandatory
	Radius 	 int		`json:"radius,omitempty"`	// max = 40000 ~25 miles
	Limit	 int		`jons:"limit,omitempty"`	// default = 20, max = 50
	SortBy	 string		`json:"sort_by,omitempty"`	// rating, distance, review_count, default = best_match
	Price 	 string		`json:"price,omitempty"`	// $, $$, $$$, $$$$
}

// ex: https://api.yelp.com/v3/businesses/search?term=taco%20truck&location=irvine&sort_by=rating&radius=20000

var queryStem = "https://api.yelp.com/v3/businesses/search?"
var yelpToken = "Bearer N9qcpKyP2tgirOpSZv-KAG3o3C4KNs3onoZ16w2Xpu7hDrBuxTCXOizcUjyIOPxCBNwbOT6i5BoBGYZI2TR5HCV_whm4fA2wm8fM8wCiKyskb0duurwmj3yUvVZPXnYx"

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
	query := queryStem + queryTerms.Encode()
	yelpReq, err := http.NewRequestWithContext(ctx, "GET", query, nil)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		return
	}
	yelpReq.Header.Set("content-type", "application/json")
	yelpReq.Header.Set("authorization", yelpToken)

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

	log.WithFields(log.Fields{"res": reqMap,}).Info("GetYelpResults: outgoing result")
	json.NewEncoder(res).Encode(reqMap)
}
