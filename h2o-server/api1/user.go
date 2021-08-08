package api1

import (
	"h2o/app"
	"h2o/model"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Users struct {
	a *app.App
}

func RegisterUsers(r *gin.RouterGroup, a *app.App) {
	u := &Users{a}
	r.POST("", Api(a), u.createUser)
	r.POST("login", Api(a), u.login)
	r.POST("logout", ApiSessionRequired(a), u.logout)
}

// @id CreateUser
// @summary Create User
// @tags USERS
// @accept json
// @produce json
// @param body body dto.CreateUserInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.CreateUserOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/users [POST]
func (u *Users) createUser(ctx *gin.Context) {
	c, err := Context(ctx)
	if err != nil {
		c.Err = err
		return
	}
	user := &model.User{}
	if err := BindBody(ctx, user); err != nil {
		c.SetInvalidParam("user")
		return
	}
	redirect := ctx.Request.URL.Query().Get("r")

	ruser, err := c.App.CreateUserFromSignup(c.AppContext, user, redirect)
	if err != nil {
		c.Err = err
		return
	}

	Success(ctx, ruser)
}

type LoginRequest struct {
	Id string `json:"id" form:"id" example:"123456"`
	// Username or email
	LoginId  string `json:"login_id" form:"login_id" example:"username"`
	Password string `json:"password" form:"password" example:""`
	DeviceId string `json:"device_id" form:"device_id" example:""`
}

// @id Login
// @summary Login
// @tags USERS
// @accept json
// @produce json
// @param body body dto.CreateUserInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.CreateUserOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/users/login [POST]
func (u *Users) login(c *gin.Context) {
	body := LoginRequest{}
	if err := BindBody(c, body); err != nil {
		Error(c, http.StatusBadRequest, err)
	}

	Success(c, "")
}

// @id Logout
// @summary Logout
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
