package user

import (
	"github.com/google/uuid"
)

type UserJson struct {
	Id    uuid.UUID   `json:"id"`
	Name  string      `json:"name"`
	Email string      `json:"email"`
	Teams []uuid.UUID `json:"teams"`
}

func New(name string, email string) UserJson {
	return UserJson{
		Id:    uuid.New(),
		Name:  name,
		Email: email,
		Teams: []uuid.UUID{},
	}
}
