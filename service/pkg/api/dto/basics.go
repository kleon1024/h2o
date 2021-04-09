package dto

import (
	"h2o/pkg/api/middleware"

	"github.com/gin-gonic/gin"
)

const (
	DefaultOffset = 0
	DefaultLimit  = 10
)

type Pagination struct {
	// 偏移，从0开始，默认为0
	Offset int `json:"offset" example:"0" validate:"min=0"`
	// 分页大小，默认为10
	Limit int `json:"limit" example:"10" validate:"min=1"`
}

func (p *Pagination) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeQuery)
}

type PaginationTotal struct {
	// 数据条目总数
	Total int `json:"total"`
}

type PaginationStream struct {
	// 是否还有后续数据
	More int `json:"more"`
}
