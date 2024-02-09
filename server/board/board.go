package board

import (
	"github.com/google/uuid"
)

type Board struct {
	Id   uuid.UUID `json:"id"`
	Name string    `json:"name"`
}

func New(name string) Board {
	return Board{
		Id:   uuid.New(),
		Name: name,
	}
}
