package dto

import (
	"h2o/pkg/api"

	"github.com/gin-gonic/gin"
)

const (
	DefaultOffset = 0
	DefaultLimit  = 10
)

type Pagination struct {
	// 偏移，从0开始，默认为0
	Offset int `json:"offset" form:"offset" example:"0" validate:"min=0"`
	// 分页大小，默认为10
	Limit int `json:"limit" form:"limit" example:"10" validate:"min=1,max=1000"`
}

func (p *Pagination) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypeQuery)
}

type PaginationOutput struct {
	// 数据条目总数
	Total int `json:"total"`
	// 是否还有后续数据
	More int `json:"more"`
}

type ShortUserOutput struct {
	ID   string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Name string `json:"name" example:"Mike"`
	Type string `json:"type"`
}
