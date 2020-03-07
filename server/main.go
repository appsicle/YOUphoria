package main

import (
	Routes "./routes"
	Mongodb "./mongodb"
	Logging "./logging"
	log "github.com/sirupsen/logrus"

	"net/http"
	"github.com/gorilla/mux"
)

func main() {
	Logging.InitLogging();
	log.Info("Application started")

	Mongodb.ConnectDB();
	r := mux.NewRouter()
	Routes.ConnectRoutes(r);
	
	http.ListenAndServe(":8080", r)
}
