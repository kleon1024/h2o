package handler

import (
	"h2o/pkg/api/dao"
	"h2o/pkg/api/middleware"
	"h2o/pkg/app"
	"h2o/pkg/model"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"github.com/sirupsen/logrus"
)

type WebSocket struct {
	Service *app.Server
}

func RegisterWebSocket(r *gin.RouterGroup, svc *app.Server) {
	h := WebSocket{svc}
	r.GET("", h.ConnectWebSocket)
}

// @id ConnectWebSocket
// @summary ConnectWebSocket
// @tags WebSocket
// @accept json
// @produce json
// @router /api/v1/ws [POST]
func (h *WebSocket) ConnectWebSocket(c *gin.Context) {
	var user dao.User
	userValue, _ := c.Get(middleware.UserKey)
	if userValue != nil {
		user = userValue.(dao.User)
	}

	upgrader := websocket.Upgrader{
		ReadBufferSize:  model.SOCKET_MAX_MESSAGE_SIZE_KB,
		WriteBufferSize: model.SOCKET_MAX_MESSAGE_SIZE_KB,
		CheckOrigin:     CheckOrigin,
	}

	ws, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		logrus.WithField("event", "ConnectWebSocket").WithError(err).Error("failed to upgrade websocket")
		return
	}

	logrus.WithField("event", "ConnectWebSocket").Info(user.ID)
	wc := app.NewWebConn(ws, user.ID.String())
	h.Service.HubRegister(wc)

	wc.Pump()
}

func CheckOrigin(r *http.Request) bool {
	return true
}
