package dto

import (
	"h2o/pkg/api/middleware"

	"github.com/gin-gonic/gin"
)

type BlockInputPath struct {
	BlockID string `json:"blockID" uri:"blockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *BlockInputPath) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypePath)
}

type BlockOutput struct {
	ID         string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	PreBlockID string `json:"preBlockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	PosBlockID string `json:"posBlockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Type       string `json:"type" example:"directory"`
	Text       string `json:"text" example:"This is an example"`
	Revision   int    `json:"revision" example:"0"`
	AuthorID   string `json:"authorID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	UpdatedAt  string `json:"updatedAt" example:"2020-01-02 15:04:03Z"`
}

type UpdateBlockInputBody struct {
	Type       string `json:"type" example:"text" validate:"required"`
	Text       string `json:"text" example:"text"`
	NodeID     string `json:"nodeID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
	SubBlockID string `json:"subBlockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
	PreBlockID string `json:"preBlockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
	PosBlockID string `json:"posBlockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *UpdateBlockInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}

type PatchBlockInputBody struct {
	Type       string `json:"type" example:"text"`
	Text       string `json:"text" example:"text"`
	NodeID     string `json:"nodeID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	SubBlockID string `json:"subBlockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	PreBlockID string `json:"preBlockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	PosBlockID string `json:"posBlockID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
}

func (p *PatchBlockInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}
