package action

import (
	"github.com/google/uuid"
)

type Status string

const (
	StatusToDo       Status = "TO_DO"
	StatusInProgress Status = "IN_PROGRESS"
	StatusComplete   Status = "COMPLETE"
)

type Action struct {
	Id       uuid.UUID `json:"id"`
	Author   uuid.UUID `json:"author"`
	Status   Status    `json:"status"`
	Assignee string    `json:"assignee"`
	Content  string    `json:"content"`
}

var DevActions = []Action{
	{
		Id:       uuid.Must(uuid.Parse("0e596f7d-fe22-4d97-baf3-f5c508702066")),
		Author:   uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960")),
		Status:   StatusToDo,
		Assignee: "Nimmo",
		Content:  "Do a thing",
	},
	{
		Id:       uuid.Must(uuid.Parse("802c1953-3358-48b3-bf51-550520b715a2")),
		Author:   uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960")),
		Status:   StatusInProgress,
		Assignee: "Abi",
		Content:  "Do another thing",
	},
	{
		Id:       uuid.Must(uuid.Parse("802c1953-3358-48b3-bf51-550520b715a3")),
		Author:   uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960")),
		Status:   StatusComplete,
		Assignee: "Abi",
		Content:  "Be awesome",
	},
	{
		Id:       uuid.Must(uuid.Parse("802c1953-3358-48b3-bf51-550520b715a1")),
		Author:   uuid.Must(uuid.Parse("9a4269ee-45f2-43ed-8e81-5cc1f6b89960")),
		Status:   StatusComplete,
		Assignee: "Neil",
		Content:  "Be awesome",
	},
}
