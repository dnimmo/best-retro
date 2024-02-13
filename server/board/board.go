package board

import (
	"bestretro/team"

	"github.com/google/uuid"
)

type Board struct {
	Id   uuid.UUID `json:"id"`
	Name string    `json:"name"`
}

func New(name string, teamId uuid.UUID) Board {
	println("Creating new board with name:", name)
	println("Adding board to team with ID:", teamId.String())

	newBoard := Board{
		Id:   uuid.New(),
		Name: name,
	}

	t := team.GetTeam(teamId)

	t.AddBoard(newBoard.Id)

	return newBoard
}
