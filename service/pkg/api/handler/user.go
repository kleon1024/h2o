package handler

import (
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/middleware"

	"github.com/gin-gonic/gin"
)

type Users struct {
	Service *options.ApiService
}

func RegisterUsers(r *gin.RouterGroup, svc *options.ApiService) {
	h := Users{svc}
	r.GET("", h.CreateUser)
}

func (h *Users) CreateUser(c *gin.Context) {
	middleware.Success(c, "Created a user")
}
