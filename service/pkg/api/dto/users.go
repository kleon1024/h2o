package dto

import (
	"h2o/pkg/api"

	"github.com/gin-gonic/gin"
)

type Token struct {
	Token     string `json:"token"`
	ExpiresAt string `json:"expiresAt"`
}

type CreateUserInputBodyType struct {
	Type string `json:"type" example:"anonymous" validate:"required"`
}

func (p *CreateUserInputBodyType) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypeBody)
}

type CreateUserInputBody struct {
	Name     string `json:"name" example:"UserName" validate:"max=18,min=3"`
	Password string `json:"password" validate:"max=30,min=6"`
	Email    string `json:"email" validate:"email"`
}

func (p *CreateUserInputBody) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypeBody)
}

type CreateUserOutput struct {
	ID           string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	AccessToken  Token  `json:"accessToken"`
	RefreshToken Token  `json:"refreshToken"`
	Name         string `json:"name" example:"UserName" validate:"max=18,min=3"`
}
