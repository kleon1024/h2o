package web

import (
	"h2o/app"
	"h2o/app/request"
	"h2o/model"
	"h2o/shared/i18n"
	"h2o/utils"
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

// func (c *Context) IsSystemAdmin() bool {
// 	return c.App.SessionHasPermissionTo(*c.AppContext.Session(), model.PermissionManageSystem)
// }

func (c *Context) LogErrorByCode(err *model.AppError) {
	code := err.StatusCode
	msg := err.SystemMessage(i18n.TDefault)
	fields := logrus.Fields{
		"err_where":   err.Where,
		"http_code":   err.StatusCode,
		"err_details": err.DetailedError,
	}
	switch {
	case (code >= http.StatusBadRequest && code < http.StatusInternalServerError) ||
		err.Id == "web.check_browser_compatibility.app_error":
		logrus.WithFields(fields).Debug(msg)
	case code == http.StatusNotImplemented:
		logrus.WithFields(fields).Info(msg)
	default:
		logrus.WithFields(fields).Error(msg)
	}
}

func (c *Context) SetInvalidParam(parameter string) {
	c.Err = NewInvalidParamError(parameter)
}

func (c *Context) SetInvalidUrlParam(parameter string) {
	c.Err = NewInvalidUrlParamError(parameter)
}

func (c *Context) SetServerBusyError() {
	c.Err = NewServerBusyError()
}

func (c *Context) SetInvalidRemoteIdError(id string) {
	c.Err = NewInvalidRemoteIdError(id)
}

func (c *Context) SetInvalidRemoteClusterTokenError() {
	c.Err = NewInvalidRemoteClusterTokenError()
}

func (c *Context) SetJSONEncodingError() {
	c.Err = NewJSONEncodingError()
}

func (c *Context) SetCommandNotFoundError() {
	c.Err = model.NewAppError("GetCommand", "store.sql_command.save.get.app_error", nil, "", http.StatusNotFound)
}

// func (c *Context) HandleEtag(etag string, routeName string, w http.ResponseWriter, r *http.Request) bool {
// 	metrics := c.App.Metrics()
// 	if et := r.Header.Get(model.HeaderEtagClient); etag != "" {
// 		if et == etag {
// 			w.Header().Set(model.HeaderEtagServer, etag)
// 			w.WriteHeader(http.StatusNotModified)
// 			if metrics != nil {
// 				metrics.IncrementEtagHitCounter(routeName)
// 			}
// 			return true
// 		}
// 	}

// 	if metrics != nil {
// 		metrics.IncrementEtagMissCounter(routeName)
// 	}

// 	return false
// }

func NewInvalidParamError(parameter string) *model.AppError {
	err := model.NewAppError("Context", "api.context.invalid_body_param.app_error", map[string]interface{}{"Name": parameter}, "", http.StatusBadRequest)
	return err
}
func NewInvalidUrlParamError(parameter string) *model.AppError {
	err := model.NewAppError("Context", "api.context.invalid_url_param.app_error", map[string]interface{}{"Name": parameter}, "", http.StatusBadRequest)
	return err
}
func NewServerBusyError() *model.AppError {
	err := model.NewAppError("Context", "api.context.server_busy.app_error", nil, "", http.StatusServiceUnavailable)
	return err
}

func NewInvalidRemoteIdError(parameter string) *model.AppError {
	err := model.NewAppError("Context", "api.context.remote_id_invalid.app_error", map[string]interface{}{"RemoteId": parameter}, "", http.StatusBadRequest)
	return err
}

func NewInvalidRemoteClusterTokenError() *model.AppError {
	err := model.NewAppError("Context", "api.context.remote_id_invalid.app_error", nil, "", http.StatusUnauthorized)
	return err
}

func NewJSONEncodingError() *model.AppError {
	err := model.NewAppError("Context", "api.context.json_encoding.app_error", nil, "", http.StatusInternalServerError)
	return err
}
