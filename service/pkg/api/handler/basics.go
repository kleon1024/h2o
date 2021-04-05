package handler

import (
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/middleware"

	"github.com/gin-gonic/gin"
)

type Basics struct {
	Service *options.ApiService
}

func RegisterBasics(r *gin.RouterGroup, svc *options.ApiService) {
	h := Basics{svc}
	r.GET("/", h.GetHello)
}

func (h *Basics) GetHello(c *gin.Context) {
	middleware.Success(c, "H2O Service")
}
