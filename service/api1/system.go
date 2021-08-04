package api1

import (
	"h2o/app"

	"github.com/gin-gonic/gin"
)

type System struct {
	a *app.App
}

func RegisterSystem(r *gin.RouterGroup, a *app.App) {
	h := &System{a}
	r.GET("/ping", Api(a), h.getSystemPing)
}

// @id GetSystemPing
// @summary Get System Ping
// @tags USERS
// @accept json
// @produce json
// @param body body dto.CreateUserInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.CreateUserOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/system/ping [GET]
func (h *System) getSystemPing(c *gin.Context) {
	Success(c, "OK")
}
