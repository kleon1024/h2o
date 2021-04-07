package dto

import (
	"h2o/pkg/api/middleware"

	"github.com/gin-gonic/gin"
)

type CreateUserInputBody struct {
	Type     string `json:"type" form:"type" example:"anonymous" validate:"required"`
	Name     string `json:"name" form:"name" example:"UserName"`
	Password string `json:"password" form:"password"`
	Email    string `json:"email" form:"email"`
}

func (p *CreateUserInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}
