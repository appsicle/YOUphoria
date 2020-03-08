package mongodb

import (
	"fmt"
	"time"
	"context"
    "go.mongodb.org/mongo-driver/mongo"
    "go.mongodb.org/mongo-driver/mongo/options"
)

var Client *mongo.Client
var ProfileCollection *mongo.Collection
var TokenCollection *mongo.Collection

func ConnectDB() {
	fmt.Println("Starting the application...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	clientOptions := options.Client().ApplyURI("mongodb+srv://testacc:testaccpw@youphoria-r8kiz.mongodb.net/test?retryWrites=true&w=majority")
	
	Client, _ = mongo.Connect(ctx, clientOptions)
	ProfileCollection = Client.Database("YOUphoria").Collection("profiles")
	TokenCollection = Client.Database("YOUphoria").Collection("tokens")
}