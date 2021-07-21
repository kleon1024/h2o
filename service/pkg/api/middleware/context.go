package middleware

import (
	"h2o/pkg/app"
	"h2o/pkg/app/request"
	"h2o/pkg/model"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

type Context struct {
	AppContext *request.Context
	App *app.App
}

func ContextHandler(a *app.App, requiredSession bool) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		now := time.Now()
		requestId := model.NewId()
		var statusCode string
		defer func() {
			responseLogFields := logrus.Fields{
				"method":     ctx.Request.Method,
				"url":        ctx.Request.URL.Path,
				"request_id": requestId,
			}

			// Websockets are returning status code 0 to requests after closing the socket
			if statusCode != "0" {
				responseLogFields["status_code"] = statusCode
			}
			logrus.WithFields(responseLogFields).Debug("Received HTTP request")
		}()

		c := &Context{
			AppContext: &request.Context{},
			App: a,
		}

		c.AppContext.SetRequestId(requestId)
		c.AppContext.SetIpAddress(ctx.ClientIP())
		c.AppContext.SetUserAgent(ctx.Request.Header.Get("User-Agent"))
		c.AppContext.SetAcceptLanguage(ctx.Request.Header.Get("Accept-Language"))
		c.AppContext.SetPath(ctx.Request.URL.Path)

		token, tokenLocation := app.ParseAuthTokenFromRequest(ctx)

		if token != "" {
			session, err := c.App.
		}
	}
}
