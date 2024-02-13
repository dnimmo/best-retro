package main

import (
	"bestretro/action"
	"bestretro/board"
	"bestretro/team"
	"bestretro/user"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func setHeaders(w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
}

func main() {
	api := gin.Default()

	api.Use(corsMiddleware())

	api.GET("/auth", func(c *gin.Context) {
		c.JSON(200, user.DevUser)
	})

	api.POST("/teams", func(c *gin.Context) {
		// userId := c.PostForm("userId")

		c.JSON(200, team.DevTeams)
	})

	api.POST("/team-members", func(c *gin.Context) {
		c.JSON(200, team.DevTeamMemberDetails)
	})

	api.POST("/team", func(c *gin.Context) {
		var requestBody struct {
			ID uuid.UUID `json:"id"`
		}
		if err := c.BindJSON(&requestBody); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
			return
		}

		teamID := requestBody.ID

		fetchedTeam := team.GetTeam(teamID)
		if fetchedTeam.Id == uuid.Nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Team not found"})
			return
		}

		c.JSON(http.StatusOK, fetchedTeam)
	})

	api.POST("/board/new", func(c *gin.Context) {
		type RequestBody struct {
			Name   string    `json:"name"`
			TeamId uuid.UUID `json:"teamId"`
		}

		var requestBody RequestBody
		if err := c.BindJSON(&requestBody); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		// Log the parsed values
		println("Received board name:", requestBody.Name)
		println("Received team ID:", requestBody.TeamId.String())

		boardName := requestBody.Name
		teamId := requestBody.TeamId
		newBoard := board.New(boardName, teamId)

		c.JSON(200, newBoard)
	})

	api.POST("/actions", func(c *gin.Context) {
		// teamId := c.PostForm("teamId")

		c.JSON(200, action.DevActions)
	})

	api.Run(":8080")
}

func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}
