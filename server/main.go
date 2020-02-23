package main

import (
	"fmt"
	Routes "./routes"
)

func main() {
	fmt.Print("Hello World\n")
	fmt.Printf("%t\n", Routes.Test(1))
}