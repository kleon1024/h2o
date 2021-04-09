package handler

import (
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/dao"
	"h2o/pkg/api/dto"
	"h2o/pkg/api/middleware"
	"h2o/pkg/config"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

type Tokens struct {
	Service *options.ApiService
}

func RegisterTokens(r *gin.RouterGroup, svc *options.ApiService) {
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
	userValue, _ := c.Get(middleware.UserKey)
	user := userValue.(dao.User)
	logrus.WithField("uid", user.ID.String()).Debug("")

	accessToken, accessTokenExpiresAt, refreshToken, refreshTokenExpiresAt, err := middleware.GenerateTokens(&user, &h.Service.Config.JWTConfig)
	if err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
	}

	middleware.Success(c, &dto.CreateUserOutput{
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
