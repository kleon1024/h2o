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
	Type string `json:"type" form:"type" validate:"required,min=1"`
	Text string `json:"text" form:"text"`
}

func (p *CreateNodeBlockInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}
