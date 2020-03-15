package main

import (
	log "github.com/sirupsen/logrus"

	"net/http"
	"github.com/gorilla/mux"
)

func main() {
	InitLogging();
	log.Info("Application started")

	ConnectDB();
	r := mux.NewRouter()
	ConnectRoutes(r);
	
	http.ListenAndServe(":8080", r)
}
