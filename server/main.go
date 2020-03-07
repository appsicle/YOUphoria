package main

import (
	// "fmt"
	// "log"
	Routes "./routes"
	Mongodb "./mongodb"
	"net/http"
	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()
	
	Routes.ConnectRoutes(r);
	Mongodb.ConnectDB();
	
	http.ListenAndServe(":8080", r)
}
