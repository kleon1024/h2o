package handler

import (
	"fmt"
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/dao"
	"h2o/pkg/api/dto"
	"h2o/pkg/api/middleware"
	"h2o/pkg/config"
	"net/http"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
)

const (
	JWTSubjectAccessToken  = "AccessToken"
	JWTSubjectRefreshToken = "RefreshToken"
)

type Users struct {
	Service *options.ApiService
}

func RegisterUsers(r *gin.RouterGroup, svc *options.ApiService) {
	h := Users{svc}
	r.POST("", h.CreateUser)
	r.POST("/tokens", h.CreateTokens)
}

func (h *Users) generateToken(subject string, expiresTime time.Time, user dao.User) (string, error) {
	claims := jwt.StandardClaims{
		Audience:  user.Name,
		ExpiresAt: expiresTime.Unix(),
		Id:        user.ID.String(),
		IssuedAt:  time.Now().Unix(),
		Issuer:    h.Service.Config.JWTConfig.Issuer,
		NotBefore: time.Now().Unix(),
		Subject:   subject,
	}
	jwtSecret := []byte(h.Service.Config.JWTConfig.Secret)
	return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(jwtSecret)
}

// @id CreateUser
// @summary 创建用户
// @description 无关联匿名账号试用，创建匿名用户，返回tokens
// @description 无关联匿名账号登录，无登录账号，创建正式账号，返回tokens
// @description 无关联匿名账号登录，有登录账号，返回tokens
// @description 有关联匿名账号登录，无登录账号，匿名账号更新为正式账号，返回tokens
// @description 有关联匿名账号登录，有登录账号，匿名账号更新为登录账号，返回tokens
// @tags 用户
// @accept json
// @produce json
// @param body body dto.CreateUserInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.CreateUserOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/users [POST]
func (h *Users) CreateUser(c *gin.Context) {
	p := &dto.CreateUserInputBodyType{}
	if err := p.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	var user dao.User
	if p.Type == dao.UserTypeAnonymous {
		user = dao.User{
			Type: dao.UserTypeAnonymous,
		}
	} else {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("unsupported user type"))
	}
	if err := user.Save(h.Service.Database); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	jwtConfig := h.Service.Config.JWTConfig
	accessTokenExpiresAt := time.Now().UTC().Add(time.Hour * time.Duration(jwtConfig.AccessTokenExpireHours))
	accessToken, err := h.generateToken(
		JWTSubjectAccessToken,
		accessTokenExpiresAt,
		user,
	)
	if err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
	}
	refreshTokenExpiresAt := time.Now().UTC().Add(time.Hour * time.Duration(jwtConfig.RefreshTokenExpireDays*24))
	refreshToken, err := h.generateToken(
		JWTSubjectRefreshToken,
		refreshTokenExpiresAt,
		user,
	)
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

// @id CreateTokens
// @summary 获取Tokens
// @description 使用refresh token获取新token
// @tags 用户
// @accept json
// @produce json
// @param body body dto.CreateUserInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.CreateUserOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/users/tokens [POST]
func (h *Users) CreateTokens(c *gin.Context) {}
