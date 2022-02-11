package main

import (
	"bufio"
	"os"
	"strings"
	"time"

	"github.com/hugolgst/rich-go/client"	
)

var now = time.Now()
var activity = &client.Activity{
	State: "Idling",
	LargeImage: "afk",
	LargeText: "Idling",
	SmallImage: "litexl",
	SmallText: "Lite XL",
	Timestamps: &client.Timestamps{
		Start: &now,
	},
}

func main() {
	err := client.Login("749282810971291659")
	if err != nil {
		panic(err)
	}
	
	done := make(chan bool)
	err = client.SetActivity(*activity)

	if err != nil {
		panic(err)
	}
	
	go func() {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			typ, data := parse(scanner.Text())
			switch typ {
				case "state":
				activity.State = data
				case "details":
				activity.Details = data
				case "bigImg":
				activity.LargeImage = data
				case "bigText":
				activity.LargeText = data
				case "send":
				client.SetActivity(*activity)
			}
		}

		if scanner.Err() != nil {
			// do thing
		}		
	}()
	<-done
}

func parse(inf string) (string, string) {
	typ := strings.Split(inf, " ")[0]
	data := strings.TrimPrefix(inf, typ)
	data = strings.TrimSpace(data)
	
	return typ, data
}