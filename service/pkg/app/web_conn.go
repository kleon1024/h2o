package app

import (
	"bytes"
	"encoding/json"
	"h2o/pkg/model"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	"github.com/sirupsen/logrus"
)

const (
	sendQueueSize          = 256
	sendSlowWarn           = (sendQueueSize * 50) / 100
	sendFullWarn           = (sendQueueSize * 95) / 100
	writeWaitTime          = 30 * time.Second
	pongWaitTime           = 100 * time.Second
	pingInterval           = (pongWaitTime * 6) / 10
	authCheckInterval      = 5 * time.Second
	webConnMemberCacheTime = 1000 * 60 * 30 // 30 minutes
)

type WebConn struct {
	// sessionExpiresAt int64 // This should stay at the top for 64-bit alignment of 64-bit words accessed atomically
	App       *App
	WebSocket *websocket.Conn
	Sequence  int64
	UserId    string

	send         chan model.WebSocketMessage
	endWritePump chan struct{}
	pumpFinished chan struct{}
}

func NewWebConn(ws *websocket.Conn, userID string) *WebConn {
	return &WebConn{
		WebSocket: ws,
		UserId:    userID,
		send:      make(chan model.WebSocketMessage, sendQueueSize),
	}
}

// Close closes the WebConn.
func (wc *WebConn) Close() {
	wc.WebSocket.Close()
	<-wc.pumpFinished
}

func (wc *WebConn) readPump() {
	defer func() {
		wc.WebSocket.Close()
	}()
	wc.WebSocket.SetReadLimit(model.SOCKET_MAX_MESSAGE_SIZE_KB)
	wc.WebSocket.SetReadDeadline(time.Now().Add(pongWaitTime))
	wc.WebSocket.SetPongHandler(func(string) error {
		wc.WebSocket.SetReadDeadline(time.Now().Add(pongWaitTime))
		// if wc.IsAuthenticated() {
		// 	wc.App.Srv().Go(func() {
		// 		wc.App.SetStatusAwayIfNeeded(wc.UserId, false)
		// 	})
		// }
		return nil
	})

	for {
		var req model.WebSocketRequest
		if err := wc.WebSocket.ReadJSON(&req); err != nil {
			wc.logSocketErr("websocket.read", err)
			return
		}
		logrus.Info(req)
	}
}

func (wc *WebConn) Pump() {
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		wc.writePump()
	}()
	wc.readPump()
	close(wc.endWritePump)
	wg.Wait()
	wc.App.HubUnregister(wc)
	close(wc.pumpFinished)
}

func (wc *WebConn) writePump() {

	defer func() {
		wc.WebSocket.Close()
	}()

	var buf bytes.Buffer
	// 2k is seen to be a good heuristic under which 98.5% of message sizes remain.
	buf.Grow(1024 * 2)
	enc := json.NewEncoder(&buf)

	for {
		select {
		case msg, ok := <-wc.send:
			if !ok {
				wc.WebSocket.SetWriteDeadline(time.Now().Add(writeWaitTime))
				wc.WebSocket.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			evt, evtOk := msg.(*model.WebSocketEvent)

			skipSend := false
			if len(wc.send) >= sendSlowWarn {
				switch msg.EventType() {
				case model.WEBSOCKET_EVENT_TYPING:
					log := logrus.WithField("user_id", wc.UserId)
					log = log.WithField("type", msg.EventType())
					log = log.WithField("node_id", evt.Broadcast.NodeId)
					log = log.WithField("event", "websocket.slow.drop_message")
					log.Warn("dropping message")
					skipSend = true
				}
			}

			if skipSend {
				continue
			}

			buf.Reset()
			var err error
			if evtOk {
				cpyEvt := evt.SetSequence(wc.Sequence)
				err = cpyEvt.Encode(enc)
				wc.Sequence++
			} else {
				err = enc.Encode(msg)
			}
			if err != nil {
				logrus.WithField("error", err).Warn("Error in encoding websocket message")
				continue
			}

			if len(wc.send) >= sendFullWarn {
				log := logrus.WithField("user_id", wc.UserId)
				log = log.WithField("type", msg.EventType())
				log = log.WithField("size", buf.Len())

				if evtOk {
					log = log.WithField("channel_id", evt.GetBroadcast().NodeId)
				}

				log.Warn("websocket.full")
			}

			wc.WebSocket.SetWriteDeadline(time.Now().Add(writeWaitTime))
			if err := wc.WebSocket.WriteMessage(websocket.TextMessage, buf.Bytes()); err != nil {
				wc.logSocketErr("websocket.send", err)
				return
			}

		case <-wc.endWritePump:
			return
		}
	}
}

func (wc *WebConn) logSocketErr(source string, err error) {
	// browsers will appear as CloseNoStatusReceived
	log := logrus.WithField("user_id", wc.UserId)
	if websocket.IsCloseError(err, websocket.CloseNormalClosure, websocket.CloseNoStatusReceived) {
		log.Debug(source + ": client side closed socket")
	} else {
		log.WithError(err).Debug(source + ": closing websocket")
	}
}

// shouldSendEvent returns whether the message should be sent or not.
func (wc *WebConn) shouldSendEvent(msg *model.WebSocketEvent) bool {
	return true
}
