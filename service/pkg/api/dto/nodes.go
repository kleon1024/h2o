package dto

import (
	"h2o/pkg/api/middleware"

	"github.com/gin-gonic/gin"
)

type ListNodeBlocksInputPath struct {
	NodeID string `json:"nodeID" uri:"nodeID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *ListNodeBlocksInputPath) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypePath)
}

type ListNodeBlocksOutput struct {
	Pagination
	Blocks []BlockOutput `json:"blocks"`
}

type CreateNodeBlockInputBody struct {
	ID         string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Type       string `json:"type" example:"text" validate:"required"`
	Text       string `json:"text" example:"text"`
	PreBlockID string `json:"preBlockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
	PosBlockID string `json:"posBlockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *CreateNodeBlockInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}

type NodeInputPath struct {
	NodeID string `json:"nodeID" uri:"nodeID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *NodeInputPath) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypePath)
}

type NodeOutput struct {
	ID        string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Type      string `json:"type" example:"directory"`
	Name      string `json:"name" example:"This is an example"`
	Indent    int    `json:"indent" example:"0" validate:"required"`
	TeamID    string `json:"teamID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
	PreNodeID string `json:"preNodeID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	PosNodeID string `json:"posNodeID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
}

type UpdateNodeInputBody struct {
	Type      string `json:"type" example:"text" validate:"required"`
	Name      string `json:"name" example:"name" validate:"required"`
	Indent    int    `json:"indent" example:"0" validate:"required,min=0"`
	TeamID    string `json:"teamID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
	PreNodeID string `json:"preNodeID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
	PosNodeID string `json:"posNodeID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *UpdateNodeInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}

type PatchNodeInputBody struct {
	Type      string `json:"type" example:"text"`
	Name      string `json:"name" example:"name"`
	Indent    int    `json:"indent" example:"0"`
	TeamID    string `json:"teamID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	PreNodeID string `json:"preNodeID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	PosNodeID string `json:"posNodeID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
}

func (p *PatchNodeInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}

type GetNodeTableOutput struct {
	ID      string   `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Columns []Column `json:"columns"`
}

type Column struct {
	ID           string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Name         string `json:"name" example:"name"`
	Type         string `json:"type" example:"type"`
	DefaultValue string `json:"defaultValue" example:"defaultValue"`
}
