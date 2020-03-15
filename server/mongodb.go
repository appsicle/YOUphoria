package main

import (
	// "fmt"
	"time"
	"context"
	"os"

    "go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/bson/primitive"

)

var Client *mongo.Client
var ProfileCollection *mongo.Collection
var TokenCollection *mongo.Collection
var CategoryCollection *mongo.Collection

func ConnectDB() {
	// fmt.Println("Starting the application...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	clientOptions := options.Client().ApplyURI(os.Getenv("MONGOURI"))

	Client, _ = mongo.Connect(ctx, clientOptions)
	ProfileCollection = Client.Database("YOUphoria").Collection("profiles")
	TokenCollection = Client.Database("YOUphoria").Collection("tokens")
	CategoryCollection = Client.Database("YOUphoria").Collection("categories")
}

func StoOI(s string) primitive.ObjectID{
	ss, _ := primitive.ObjectIDFromHex(s)
	return ss
}

