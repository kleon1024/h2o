package api

import (
	"h2o/pkg/app"
	"h2o/pkg/app/request"
	"h2o/pkg/model"
	"h2o/pkg/utils"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

type Context struct {
	AppContext *request.Context
	App        *app.App
	Err        *model.AppError
}

func (c *Context) RemoveSessionCookie(ctx *gin.Context) {
	subpath, _ := utils.GetSubpathFromConfig(c.App.Config())

	ctx.SetCookie(
		model.SessionCookieToken,
		"",
		-1,
		subpath,
		"",
		false,
		true,
	)
}

type ContextHandler struct {
	App            *app.App
	RequireSession bool
}

func ApiSessionRequired(a *app.App) gin.HandlerFunc {
	h := &ContextHandler{
		App:            a,
		RequireSession: true,
	}
	return h.Serve()
}

func Api(a *app.App) gin.HandlerFunc {
	h := &ContextHandler{
		App:            a,
		RequireSession: false,
	}
	return h.Serve()
}

func (h *ContextHandler) Serve() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		// now := time.Now()
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
			App:        h.App,
		}

		c.AppContext.SetRequestId(requestId)
		c.AppContext.SetIpAddress(ctx.ClientIP())
		c.AppContext.SetUserAgent(ctx.Request.Header.Get("User-Agent"))
		c.AppContext.SetAcceptLanguage(ctx.Request.Header.Get("Accept-Language"))
		c.AppContext.SetPath(ctx.Request.URL.Path)

		ctx.Set("context", c)

		token, tokenLocation := app.ParseAuthTokenFromRequest(ctx)

		if token != "" {
			session, err := c.App.GetSession(token)
			if err != nil {
				if err != nil {
					if err.StatusCode == http.StatusInternalServerError {
						c.Err = err
					} else if h.RequireSession {
						c.RemoveSessionCookie(ctx)
						c.Err = model.NewAppError("ServeHTTP", "api.context.session_expired.app_error", nil, "token="+token, http.StatusUnauthorized)
					}
				} else if !session.IsOAuth && tokenLocation == app.TokenLocationQueryString {
					c.Err = model.NewAppError("ServeHTTP", "api.context.token_provided.app_error", nil, "token="+token, http.StatusUnauthorized)
				} else {
					c.AppContext.SetSession(session)
				}
			}
		}
	}
}
