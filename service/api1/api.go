package api1

import (
	"h2o/app"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

const (
	BasePath = "/api/v1"
)

type API struct {
	app    *app.App
	Routes *gin.Engine
}

func Init(a *app.App, r *gin.Engine) *API {
	api := &API{app: a, Routes: r}

	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	r.Use(cors.New(config))

	if *a.Srv().Config().RateLimitSettings.Enable {
		logrus.Info("RateLimiter is enabled")
	}

	RegisterUsers(r.Group(BasePath+"/users"), a)
	RegisterSystem(r.Group(BasePath+"/system"), a)

	return api
}
