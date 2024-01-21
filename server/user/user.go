package user

import (
	"github.com/google/uuid"
)

type User struct {
	Id    uuid.UUID   `json:"id"`
	Name  string      `json:"name"`
	Email string      `json:"email"`
	Teams []uuid.UUID `json:"teams"`
}

func New(name string, email string) User {
	return User{
		Id:    uuid.New(),
		Name:  name,
		Email: email,
		Teams: []uuid.UUID{},
	}
}

var DevUser User = User{
	Id:    uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960")),
	Name:  "Nimmo",
	Email: "dnimmo@gmail.com",
	Teams: []uuid.UUID{uuid.Must(uuid.Parse("0e596f7d-fe22-4d97-baf3-f5c508702066")),
		uuid.Must(uuid.Parse("802c1953-3358-48b3-bf51-550520b715af"))},
}
