package main

import (
	"bestretro/action"
	"bestretro/team"
	"bestretro/user"
	"encoding/json"
	"log"
	"net/http"
)

func setHeaders(w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
}

func main() {
	http.HandleFunc("/auth", func(w http.ResponseWriter, r *http.Request) {
		setHeaders(w)

		json.NewEncoder(w).Encode(user.DevUser)
	})

	http.HandleFunc("/teams", func(w http.ResponseWriter, r *http.Request) {
		setHeaders(w)

		json.NewEncoder(w).Encode(team.DevTeams)
	})

	http.HandleFunc("/team/someId", func(w http.ResponseWriter, r *http.Request) {
		setHeaders(w)

		json.NewEncoder(w).Encode(team.DevTeamMemberDetails)
	})

	http.HandleFunc("/actions/team/someId", func(w http.ResponseWriter, r *http.Request) {
		setHeaders(w)

		json.NewEncoder(w).Encode(action.DevActions)
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}
