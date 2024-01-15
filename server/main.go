package main

import (
	"bestretro/user"
	"encoding/json"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/auth", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")

		newUser := user.New(
			"Nimmo",
			"dnimmo@gmail.com",
		)

		json.NewEncoder(w).Encode(newUser)
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}
