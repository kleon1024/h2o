package handler

import (
	"h2o/api"
	"h2o/app"

	"github.com/gin-gonic/gin"
)

type Basics struct {
	Service *app.Server
}

func RegisterBasics(r *gin.RouterGroup, svc *app.Server) {
	h := Basics{svc}
	r.GET("", h.GetHello)
}

func (h *Basics) GetHello(c *gin.Context) {
	api.Success(c, "H2O Service")
}
