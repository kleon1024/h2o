package api1

import (
	"h2o/app"
	"h2o/app/request"
	"h2o/model"
	"h2o/web"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

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

		c := &web.Context{
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

		if c.Err != nil {
			ctx.Next()
		}

		if c.Err != nil {
			c.Err.RequestId = c.AppContext.RequestId()
			c.LogErrorByCode(c.Err)

			c.Err.Where = ctx.Request.URL.Path

			// Block out detailed error when not in developer mode
			if !*c.App.Config().ServiceSettings.EnableDeveloper {
				c.Err.DetailedError = ""
			}

			ctx.Writer.WriteHeader(c.Err.StatusCode)
			ctx.Writer.Write([]byte(c.Err.ToJson()))

		}
	}

}

func Context(ctx *gin.Context) (*web.Context, *model.AppError) {
	var c *web.Context
	if ctxInter, exists := ctx.Get("context"); exists {
		c = ctxInter.(*web.Context)
	} else {
		return c, model.NewAppError("Context", "api.context.load_err.app_error", nil, "", http.StatusInternalServerError)
	}
	return c, nil
}
