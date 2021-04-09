package dto

import (
	"h2o/pkg/api/middleware"

	"github.com/gin-gonic/gin"
)

type ListTeamsOutput struct {
	Pagination
	PaginationStream
	Teams []ListTeamsInstance `json:"teams"`
}

type ListTeamsInstance struct {
	ID   string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Name string `json:"name" example:"UserName" validate:"max=18,min=3"`
}

type ListTeamNodesInputPath struct {
	TeamID string `json:"teamID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"uuid"`
}

func (p *ListTeamNodesInputPath) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypePath)
}

type ListTeamNodesOutput struct {
	Pagination
	PaginationStream
	Nodes []ListTeamNodesInstance `json:"nodes"`
}

type ListTeamNodesInstance struct {
	ID       string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Type     string `json:"type" example:"directory"`
	ParentID string `json:"parentID"`
}

type CreateTeamNodeInputBody struct {
	ParentID string `json:"parentID"`
}

func (p *CreateTeamNodeInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}
