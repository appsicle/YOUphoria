package routes

import (
	"fmt"
	"net/http"
)

func YelpHandler(res http.ResponseWriter, req *http.Request){
	fmt.Fprintf(res, "Yelp")
}