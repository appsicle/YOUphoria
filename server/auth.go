package main

import (
	"net/http"
	"strings"
	"context"
	"encoding/json"
	"io/ioutil"
	"io"

	"time"
	// log "github.com/sirupsen/logrus"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Token is...
type Token struct {
	Token	string     		   `json:"token"`
	PID		primitive.ObjectID `json:"pid"`
}

func Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
		_, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		reqAuthHeader := req.Header.Get("Authorization")
		if reqAuthHeader == "" || !strings.HasPrefix(reqAuthHeader, "Bearer ") {
			http.Error(res, "Unauthorized", http.StatusUnauthorized)
		}else{
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()
			
			reqToken := strings.Split(reqAuthHeader, "Bearer ")[1]

			// map req body
			reqMap := make(map[string]interface{})
			if err := json.NewDecoder(req.Body).Decode(&reqMap); err != io.EOF && err != nil {
				http.Error(res, err.Error(), http.StatusBadRequest)
				return
			}

			// get PID by token
			var token Token
			token.Token = reqToken
			if err := TokenCollection.FindOne(ctx, bson.M{"token": token.Token}).Decode(&token); err != nil {
				res.WriteHeader(http.StatusInternalServerError)
				res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
				return
			}

			reqMap["id"] = token.PID
			reqMap["token"] = token.Token
			
			json, _ := json.Marshal(reqMap);
			req.Body = ioutil.NopCloser(strings.NewReader(string(json)))
			next.ServeHTTP(res, req)
		}
	})
}