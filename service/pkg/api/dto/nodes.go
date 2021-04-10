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
	Blocks []ListNodeBlocksInstance `json:"blocks"`
}

type ListNodeBlocksInstance struct {
	ID        string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Type      string `json:"type" example:"directory"`
	Text      string `json:"text" example:"This is an example"`
	Revision  int    `json:"revision" example:"0"`
	AuthorID  string `json:"authorID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	UpdatedAt string `json:"updatedAt" example:"2020-01-02 15:04:03Z"`
}

type CreateNodeBlockInputBody struct {
	Type string `json:"type" form:"type" validate:"required,min=1"`
	Text string `json:"text" form:"text" validate:"required"`
}

func (p *CreateNodeBlockInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}
