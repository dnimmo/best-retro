package main

import (
	"bestretro/action"
	"bestretro/board"
	"bestretro/team"
	"bestretro/user"
	"encoding/json"
	"log"
	"net/http"
	// "database/sql"
	// "github.com/lib/pq"
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

	http.HandleFunc("/team/0e596f7d-fe22-4d97-baf3-f5c508702066", func(w http.ResponseWriter, r *http.Request) {
		setHeaders(w)

		json.NewEncoder(w).Encode(team.DevTeam)
	})

	http.HandleFunc("/team/someId", func(w http.ResponseWriter, r *http.Request) {
		setHeaders(w)

		json.NewEncoder(w).Encode(team.DevTeamMemberDetails)
	})

	http.HandleFunc("/actions/team/someId", func(w http.ResponseWriter, r *http.Request) {
		setHeaders(w)

		json.NewEncoder(w).Encode(action.DevActions)
	})

	http.HandleFunc("/board/new", func(w http.ResponseWriter, r *http.Request) {
		setHeaders(w)

		var newBoard = board.New("Todo set board name via API")

		json.NewEncoder(w).Encode(newBoard)
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}
