package routes

import (
	"fmt"
	"net/http"
)

func YelpHandler(w http.ResponseWriter, r *http.Request){
	fmt.Fprintf(w, "Yelp")
}