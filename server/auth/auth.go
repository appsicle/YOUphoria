package auth

import (
	"net/http"
	"strings"
	"context"
	"time"
	log "github.com/sirupsen/logrus"


	// Mongodb "../mongodb"

	// "go.mongodb.org/mongo-driver/bson"
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
			reqToken := strings.Split(reqAuthHeader, "Bearer ")[1]
			log.Info(reqToken)
			next.ServeHTTP(res, req)
		}


		

		// get PID by token
		// var token Token
		// filter := bson.M{"token": reqToken}
		// if err := Mongodb.TokenCollection.FindOne(ctx, filter).Decode(&token); err != nil {
		// 	res.WriteHeader(http.StatusInternalServerError)
		// 	res.Write([]byte(`{ "message": "` + err.Error() + `"}`))
		// 	http.Error(res, "Forbidden", http.StatusForbidden)
		// }
	})
}