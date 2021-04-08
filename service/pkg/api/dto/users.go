package dto

import (
	"h2o/pkg/api/middleware"

	"github.com/gin-gonic/gin"
)

type Token struct {
	Token     string `json:"token" form:"token"`
	ExpiresAt string `json:"expiresAt" form:"expiresAt"`
}

type CreateUserInputBodyType struct {
	Type string `json:"type" form:"type" example:"anonymous" validate:"required"`
}

func (p *CreateUserInputBodyType) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}

type CreateUserInputBody struct {
	Name     string `json:"name" form:"name" example:"UserName" validate:"max=18,min=3"`
	Password string `json:"password" form:"password" validate:"max=30,min=6"`
	Email    string `json:"email" form:"email" validate:"email"`
}

func (p *CreateUserInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}

type CreateUserOutput struct {
	ID           string `json:"id" form:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	AccessToken  Token  `json:"accessToken" form:"accessToken"`
	RefreshToken Token  `json:"refreshToken" form:"refreshToken"`
	Name         string `json:"name" form:"name" example:"UserName" validate:"max=18,min=3"`
}
