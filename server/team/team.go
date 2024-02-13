package team

import (
	"fmt"

	"github.com/google/uuid"
)

type Team struct {
	Id      uuid.UUID   `json:"id"`
	Name    string      `json:"name"`
	Members []uuid.UUID `json:"members"`
	Actions []uuid.UUID `json:"actions"`
	Creator uuid.UUID   `json:"creator"`
	Admins  []uuid.UUID `json:"admins"`
	Boards  []uuid.UUID `json:"boards"`
}

func New(name string, creator uuid.UUID) Team {
	return Team{
		Id:      uuid.New(),
		Name:    name,
		Members: []uuid.UUID{creator},
		Actions: []uuid.UUID{},
		Creator: creator,
		Admins:  []uuid.UUID{creator},
		Boards:  []uuid.UUID{},
	}
}

var DevTeam Team = Team{
	Id:      uuid.Must(uuid.Parse("0e596f7d-fe22-4d97-baf3-f5c508702066")),
	Name:    "BR Dev Team 1",
	Members: []uuid.UUID{uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960"))},
	Actions: []uuid.UUID{},
	Creator: uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960")),
	Admins:  []uuid.UUID{uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960"))},
	Boards:  []uuid.UUID{},
}

var DevTeams = []Team{
	DevTeam,
	{

		Id:      uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960")),
		Name:    "BR Dev Team 2",
		Members: []uuid.UUID{uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960"))},
		Actions: []uuid.UUID{},
		Creator: uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960")),
		Admins:  []uuid.UUID{uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960"))},
		Boards:  []uuid.UUID{},
	},
}

func GetTeam(id uuid.UUID) Team {
	println("Getting team with ID:", id.String())
	for _, team := range DevTeams {
		if team.Id == id {
			return team
		}
	}
	return Team{}
}

func (t *Team) AddBoard(boardId uuid.UUID) {
	fmt.Println("Boards before:", t.Boards)
	t.Boards = append(t.Boards, boardId)
	fmt.Println("Boards after:", t.Boards)
}

type TeamMemberDetails struct {
	Name  string `json:"name"`
	Email string `json:"email"`
	Id    string `json:"id"`
}

var DevTeamMemberDetails = []TeamMemberDetails{
	{Name: "Nimmo",
		Email: "dnimmo@gmail.com",
		Id:    "9a4269ee-45f2-43ed-8e81-5cc1f6b89960",
	},
	{Name: "Abi",
		Email: "abi@abimail.com",
		Id:    "802c1953-3358-48b3-bf51-550520b715af",
	},
	{Name: "Neil",
		Email: "neil@kovertsmail.com",
		Id:    "0e596f7d-fe22-4d97-baf3-f5c508702066",
	},
	{Name: "Dante",
		Email: "dante@catmail.com",
		Id:    "0e596f7d-fe22-4d97-baf3-f5c508702067",
	},
}
