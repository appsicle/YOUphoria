package main

import (
	// "fmt"
	// "log"
	Routes "./routes"
	"net/http"
	"github.com/gorilla/mux"
)

// func main() {
// 	fmt.Print("Hello World\n")
// 	fmt.Printf("%t\n", Routes.Test(1))


// 	http.HandleFunc("/", func (w http.ResponseWriter, r *http.Request) {
// 		fmt.Fprintf(w, "Go RESTful Series")
// 	})

// 	log.Fatal(http.ListenAndServe(":8080", nil))
// }

// func HomeHandler(w http.ResponseWriter, r *http.Request){
// 	fmt.Fprintf(w, "Go RESTful Series")
// }

func main() {
	r := mux.NewRouter()
	
	Routes.ConnectRoutes(r);
	
	http.ListenAndServe(":8080", r)
}var client *mongo.Client
