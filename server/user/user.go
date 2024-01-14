package user

type UserJson struct {
	Id    string   `json:"id"`
	Name  string   `json:"name"`
	Email string   `json:"email"`
	Teams []string `json:"teams"`
}

func New(name string, email string, teams []string) UserJson {
	return UserJson{
		Id:    "cceba0c3-05f5-4295-b309-7016cf867973",
		Name:  name,
		Email: email,
		Teams: teams,
	}
}
