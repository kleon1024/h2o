package handler

import (
	"fmt"
	"h2o/api"
	"h2o/api/dao"
	"h2o/api/dto"
	"h2o/app"
	"h2o/config"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

type Users struct {
	Service *app.Server
}

func RegisterUsers(r *gin.RouterGroup, svc *app.Server) {
	h := Users{svc}
	r.POST("", h.CreateUser)
}

// @id CreateUser
// @summary 创建用户
// @description 无关联匿名账号试用，创建匿名用户，返回tokens
// @description 无关联匿名账号登录，无登录账号，创建正式账号，返回tokens
// @description 无关联匿名账号登录，有登录账号，返回tokens
// @description 有关联匿名账号登录，无登录账号，匿名账号更新为正式账号，返回tokens
// @description 有关联匿名账号登录，有登录账号，匿名账号更新为登录账号，返回tokens
// @tags User
// @accept json
// @produce json
// @param body body dto.CreateUserInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.CreateUserOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/users [POST]
func (h *Users) CreateUser(c *gin.Context) {
	var user dao.User
	userValue, _ := c.Get(api.UserKey)
	if userValue != nil {
		user = userValue.(dao.User)
	}

	p := &dto.CreateUserInputBodyType{}
	if err := p.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	if p.Type == dao.UserTypeAnonymous {
		if userValue == nil {
			user = dao.User{
				Type: dao.UserTypeAnonymous,
			}
			if err := user.Save(h.Service.Database); err != nil {
				api.Error(c, http.StatusBadRequest, err)
				return
			}
			team := dao.Team{
				Name: user.Name,
				// Members:   []dao.User{user},
				CreatedUserID: user.ID,
				UpdatedUserID: user.ID,
				CreatedAt:     time.Now().UTC(),
				UpdatedAt:     time.Now().UTC(),
				DeletedAt:     time.Now().UTC(),
				Deleted:       0,
			}
			if err := team.Save(h.Service.Database); err != nil {
				api.Error(c, http.StatusBadRequest, err)
				return
			}
			teamMember := dao.TeamMember{
				TeamID:    team.ID,
				UserID:    user.ID,
				CreatedAt: time.Now().UTC(),
			}
			if err := teamMember.Save(h.Service.Database); err != nil {
				api.Error(c, http.StatusBadRequest, err)
				return
			}
		} else {
			api.Error(c, http.StatusBadRequest, fmt.Errorf("user exists and token usable"))
		}
	} else {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("unsupported user type"))
	}

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
