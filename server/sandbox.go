package main 

import (
	"go.mongodb.org/mongo-driver/mongo"
	"context"
	// "encoding/json"
	// "net/http"
	"time"
	"fmt"
	// "strings"

	Mongodb "./mongodb"
	log "github.com/sirupsen/logrus"
	// "github.com/google/uuid"
	// "github.com/mitchellh/mapstructure"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func Sandbox_test(){
	
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	p, _ := primitive.ObjectIDFromHex("5e642fda9f9213049cbef7d7")
	// filter := bson.M{"id": p,}

	// filter := bson.M{ "$and": []interface{}{
	// 	bson.M{"username": reqMap["username"]}, 
	// 	bson.M{"email": reqMap["email"]}}}

	filter := bson.M{ "$and": []interface{}{		
				bson.M{ "id" : p },
				bson.M{ "calendar" : 
					bson.M{ "$elemMatch" : 
						bson.M{"date": "01/02/12"}}}}}
			// { data: { $elemMatch: { type: a, value: DBRef(...)}}},
			// { data: { $elemMatch: { type: b, value: "string"}}}


	// opts := options.Update().SetUpsert(true)
	// update := bson.M{"$push": bson.M{"calendar" : "hello"}}


	update := bson.M{"$push": bson.M{"calendar" : "hello"}}

	// update := bson.M{"$addToSet": bson.M{"calendar" : 
	// 	bson.M{"date" : "helsdlo"}}}

	res, err := Mongodb.ProfileCollection.UpdateOne(ctx, filter, update)
	if err != nil {
		log.Info(err)

		return
	}

	log.Info(res.MatchedCount)
}

// Mood is...
type Mood struct {
	Mood	int		`json:"mood"`
	Date 	string	`json:"date"`
	Time 	string	`json:"time"`
}

func Sandbox_test2(){
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// findOptions := options.Find()

	// findOptions.SetSort(bson.D{{"calendar" , 1}})
	// findOptions.SetLimit(1)

	o1 := bson.D{{"$match", 
		bson.D{{"username", "user1"}}}}

	o2 := bson.D{{"$unwind","$calendar"}}

	o3 := bson.D{{"$orderby", bson.D{{"mood", -1}}}}
	// o3 := bson.D{{"$max", }}

	// o4 := bson.D{{"$limit", 1}}

	// operations := []bson.D{o2, o3, o4}
	cursor, err := Mongodb.ProfileCollection.Aggregate(ctx, mongo.Pipeline{o1, o2, o3})
	if err != nil {
		log.Info(err)
		return
	}

	// Mongodb.ProfileCollection.Pipeline


	// Mongodb.ProfileCollection.Pipeline()

	// var mood Mood
	// cursor, err := Mongodb.ProfileCollection.Find(ctx, bson.D{}, findOptions)

	var showsLoaded []bson.M

	if err = cursor.All(ctx, &showsLoaded); err != nil {
		panic(err)
	}
	fmt.Println(showsLoaded)

	// for cursor.Next(context.TODO()) {
	// 	cursor.Decode(&mood)
	// 	log.Info(mood)

	// }
}

func Sandbox_test3(){
	// ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	// defer cancel()

	// filter := bson.M{"username": "user1"}
	// selecter := bson.M{"date" : "2020-02-06"}
	// cursor, _ := Mongodb.ProfileCollection.Find(ctx, filter)
	// items := cursor.Select(selector).Iter()
	
	// if err := Mongodb.ProfileCollection.FindOne(ctx, filter).Decode(&calendar); err != nil {
	// 	fmt.Print(err)
	// 	return
	// }

}



func Sandbox_test4(){
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	findOptions := options.Find() // build a `findOptions`
	findOptions.SetSort(map[string]int{"when": -1}) // reverse order by `when`
	findOptions.SetSkip(0) // skip whatever you want, like `offset` clause in mysql
	findOptions.SetLimit(10) // like `limit` clause in mysql

	// apply findOptions
	cur, err := Mongodb.ProfileCollection.Find(ctx, bson.D{}, findOptions)
	// resolve err
	if err != nil {
		fmt.Print(err)
		return
	}

	for cur.Next(ctx) {
	// call cur.Decode()
	}

}