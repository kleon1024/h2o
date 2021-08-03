package handler

import (
	"h2o/api"
	"h2o/api/dao"
	"h2o/api/dto"
	"h2o/app"
	"h2o/config"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Tokens struct {
	Service *app.Server
}

func RegisterTokens(r *gin.RouterGroup, svc *app.Server) {
	h := Tokens{svc}
	r.GET("", h.GetTokens)
}

// @id GetTokens
// @summary 获取Tokens
// @description 使用refresh token获取新token
// @tags Token
// @produce json
// @success 200 {object} middleware.Response{data=dto.CreateUserOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/users/tokens [Get]
func (h *Tokens) GetTokens(c *gin.Context) {
	userValue, _ := c.Get(api.UserKey)
	user := userValue.(dao.User)

	accessToken, accessTokenExpiresAt, refreshToken, refreshTokenExpiresAt, err := api.GenerateTokens(&user, &h.Service.ServiceConfig.JWTConfig)
	if err != nil {
		api.Error(c, http.StatusBadRequest, err)
	}

	api.Success(c, &dto.CreateUserOutput{
		ID:   user.ID.String(),
		Name: user.Name,
		AccessToken: dto.Token{
			Token:     accessToken,
			ExpiresAt: accessTokenExpiresAt.Format(config.DateFormatString),
		},
		RefreshToken: dto.Token{
			Token:     refreshToken,
			ExpiresAt: refreshTokenExpiresAt.Format(config.DateFormatString),
		},
	})
}
