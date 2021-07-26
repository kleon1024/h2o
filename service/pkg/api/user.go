package api

import (
	"h2o/pkg/app"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Users struct {
	a *app.App
}

func RegisterUsers(r *gin.RouterGroup, a *app.App) {
	u := &Users{a}
	r.POST("", ContextHandler(a, false), u.createUser)

	r.POST("login", ContextHandler(a, false), u.login)
	r.POST("logout", ContextHandler(a, true), u.logout)
}

// @id CreateUser
// @summary 创建用户
// @description 无关联匿名账号试用，创建匿名用户，返回tokens
// @description 无关联匿名账号登录，无登录账号，创建正式账号，返回tokens
// @description 无关联匿名账号登录，有登录账号，返回tokens
// @description 有关联匿名账号登录，无登录账号，匿名账号更新为正式账号，返回tokens
// @description 有关联匿名账号登录，有登录账号，匿名账号更新为登录账号，返回tokens
// @tags USERS
// @accept json
// @produce json
// @param body body dto.CreateUserInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.CreateUserOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/users [POST]
func (u *Users) createUser(c *gin.Context) {
	// var ctx *middleware.Context
	// if ctxInter, exists := c.Get("context"); exists {
	// 	ctx = ctxInter.(*middleware.Context)
	// } else {
	// 	Error(c, http.StatusInternalServerError, fmt.Errorf("cannot load app context"))
	// }

	Success(c, "")
}

type LoginRequest struct {
	Id string `json:"id" form:"id" example:"123456"`
	// Username or email
	LoginId  string `json:"login_id" form:"login_id" example:"username"`
	Password string `json:"password" form:"password" example:""`
	DeviceId string `json:"device_id" form:"device_id" example:""`
}

func (p *LoginRequest) Bind(c *gin.Context) error {
	return GetValidParams(c, p, BindTypeQuery)
}

// @id Login
// @summary 登录
// @tags USERS
// @accept json
// @produce json
// @param body body dto.CreateUserInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.CreateUserOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/users/login [POST]
func (u *Users) login(c *gin.Context) {
	body := LoginRequest{}
	if err := body.Bind(c); err != nil {
		Error(c, http.StatusBadRequest, err)
	}

	Success(c, "")
}

// @id Logout
// @summary 登录
// @tags USERS
// @accept json
// @produce json
// @param body body dto.CreateUserInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.CreateUserOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/users/login [POST]
func (u *Users) logout(c *gin.Context) {
	// ctx, _ := c.Get("context")

	Success(c, "")
}
