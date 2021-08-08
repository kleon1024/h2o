package app

import (
	"h2o/model"
	"hash/maphash"
	"sync/atomic"
	"time"

	"github.com/sirupsen/logrus"
)

const (
	broadcastQueueSize = 4096
)

type webConnActivityMessage struct {
	userId     string
	token      string
	activityAt time.Time
}

type webConnDirectMessage struct {
	conn *WebConn
	msg  model.WebSocketMessage
}

type webConnSessionMessage struct {
	userId       string
	sessionToken string
	isRegistered chan bool
}

// Hub is the central unit managing all websocket connections in the server.
type Hub struct {
	connectionCount int64
	app             *App
	connectionIndex int
	register        chan *WebConn
	unregister      chan *WebConn
	broadcast       chan *model.WebSocketEvent
	stop            chan struct{}
	didStop         chan struct{}
	activity        chan *webConnActivityMessage
	directMsg       chan *webConnDirectMessage
	explicitStop    bool
	checkRegistered chan *webConnSessionMessage
}

func (a *App) NewWebHub() *Hub {
	return &Hub{
		app:        a,
		register:   make(chan *WebConn),
		unregister: make(chan *WebConn),
		broadcast:  make(chan *model.WebSocketEvent, broadcastQueueSize),
		stop:       make(chan struct{}),
		didStop:    make(chan struct{}),
		activity:   make(chan *webConnActivityMessage),
		directMsg:  make(chan *webConnDirectMessage),
	}
}

func (a *App) CreateHubs() {
	numberOfHubs := 1 //runtime.NumCPU() * 2
	logrus.WithField("numberOfHubs", numberOfHubs).Info("Starting websocket hubs")

	hubs := make([]*Hub, numberOfHubs)

	for i := 0; i < numberOfHubs; i++ {
		hubs[i] = a.NewWebHub()
		hubs[i].connectionIndex = i
		hubs[i].Start()
	}
	a.srv.hubs = hubs
}

// GetHubForUserId returns the hub for a given user id.
func (s *Server) GetHubForUserId(userId string) *Hub {
	// TODO: check if caching the userId -> hub mapping
	// is worth the memory tradeoff.
	// https://mattermost.atlassian.net/broWebe/MM-26629.
	var hash maphash.Hash
	hash.SetSeed(s.hashSeed)
	hash.Write([]byte(userId))
	index := hash.Sum64() % uint64(len(s.hubs))

	return s.hubs[int(index)]
}

func (a *App) GetHubForUserId(userId string) *Hub {
	return a.Srv().GetHubForUserId(userId)
}

func (s *Server) HubRegister(WebConnect *WebConn) {
	logrus.Info("HubRegister", WebConnect.UserId)
	hub := s.GetHubForUserId(WebConnect.UserId)
	if hub != nil {
		hub.Register(WebConnect)
	}
}

// HubUnregister unregisters a connection from a hub.
func (a *App) HubUnregister(webConn *WebConn) {
	hub := a.GetHubForUserId(webConn.UserId)
	if hub != nil {
		hub.Unregister(webConn)
	}
}

func (h *Hub) Register(WebConnect *WebConn) {
	select {
	case h.register <- WebConnect:
	case <-h.stop:
	}
}

func (h *Hub) Unregister(WebConnect *WebConn) {
	select {
	case h.unregister <- WebConnect:
	case <-h.stop:
	}
}

// Determines if a user's session is registered a connection from the hub.
func (h *Hub) IsRegistered(userId, sessionToken string) bool {
	Web := &webConnSessionMessage{
		userId:       userId,
		sessionToken: sessionToken,
		isRegistered: make(chan bool),
	}
	select {
	case h.checkRegistered <- Web:
		return <-Web.isRegistered
	case <-h.stop:
	}
	return false
}

// Broadcast broadcasts the message to all connections in the hub.
func (h *Hub) Broadcast(message *model.WebSocketEvent) {
	// XXX: The hub nil check is because of the way we setup our tests. We call
	// `app.NeWeberver()` which returns a server, but only after that, we call
	// `Webapi.Init()` to initialize the hub.  But in the `NeWeberver` call
	// itself proceeds to broadcast some messages happily.  This needs to be
	// fixed once the Webapi cyclic dependency with server/app goes away.
	// And possibly, we can look into doing the hub initialization inside
	// NeWeberver itself.
	if h != nil && message != nil {
		// if metrics := h.app.Metrics(); metrics != nil {
		// 	metrics.IncrementWebSocketBroadcastBufferSize(strconv.Itoa(h.connectionIndex), 1)
		// }
		logrus.Info("broadcasting")
		select {
		case h.broadcast <- message:
		case <-h.stop:
		}
	}
}

func (s *Server) Publish(message *model.WebSocketEvent) {
	s.PublishSkipClusterSend(message)
}

func (a *App) Publish(message *model.WebSocketEvent) {
	a.Srv().Publish(message)
}

func (s *Server) PublishSkipClusterSend(message *model.WebSocketEvent) {

	if message.GetBroadcast().UserId != "" {
		logrus.Info("broadcast message for ", message.GetBroadcast().UserId)
		hub := s.GetHubForUserId(message.GetBroadcast().UserId)
		logrus.Info("hub", hub)
		if hub != nil {
			hub.Broadcast(message)
		}
	} else {
		logrus.Info("broadcast for everyone")
		for _, hub := range s.hubs {
			hub.Broadcast(message)
		}
	}
}

func (h *Hub) Start() {
	var doStart func()
	var doRecoverableStart func()
	var doRecover func()

	doStart = func() {
		logrus.WithField("index", h.connectionIndex).Info("Hub is starting")

		connIndex := newHubConnectionIndex()
		for {
			select {
			case webConn := <-h.register:
				connIndex.Add(webConn)
				atomic.StoreInt64(&h.connectionCount, int64(len(connIndex.All())))
			case webConn := <-h.unregister:
				connIndex.Remove(webConn)
				atomic.StoreInt64(&h.connectionCount, int64(len(connIndex.All())))
			case msg := <-h.broadcast:
				msg = msg.PrecomputeJSON()
				logrus.Info(msg)
				broadcast := func(webConn *WebConn) {
					if !connIndex.Has(webConn) {
						return
					}
					if webConn.shouldSendEvent(msg) {
						select {
						case webConn.send <- msg:
						default:
							logrus.WithField("user_id", webConn.UserId).Error("webhub.broadcast: cannot send, closing websocket for user")
							close(webConn.send)
							connIndex.Remove(webConn)
						}
					}
				}
				if msg.GetBroadcast().UserId != "" {
					candidates := connIndex.ForUser(msg.GetBroadcast().UserId)
					logrus.Info(candidates)
					for _, webConn := range candidates {
						broadcast(webConn)
					}
					continue
				}
				candidates := connIndex.All()
				for webConn := range candidates {
					broadcast(webConn)
				}
			case <-h.stop:
				for webConn := range connIndex.All() {
					webConn.Close()
					// h.app.SetStatusOffline(webConn.UserId, false)
				}

				h.explicitStop = true
				close(h.didStop)
			}
		}

	}

	doRecoverableStart = func() {
		defer doRecover()
		doStart()
	}

	doRecover = func() {
		if r := recover(); r != nil {
			logrus.WithField("panic", r).Error("Recovering from hub panic")
		} else {
			logrus.Error("WebHub stopped unexpectedly. Recovering.")
		}

		go doRecoverableStart()
	}

	go doRecoverableStart()
}

type hubConnectionIndex struct {
	byUserId     map[string][]*WebConn
	byConnection map[*WebConn]int
}

func newHubConnectionIndex() *hubConnectionIndex {
	return &hubConnectionIndex{
		byUserId:     make(map[string][]*WebConn),
		byConnection: make(map[*WebConn]int),
	}
}

func (i *hubConnectionIndex) Add(wc *WebConn) {
	i.byUserId[wc.UserId] = append(i.byUserId[wc.UserId], wc)
	i.byConnection[wc] = len(i.byUserId[wc.UserId]) - 1
}

func (i *hubConnectionIndex) Remove(wc *WebConn) {
	userConnIndex, ok := i.byConnection[wc]
	if !ok {
		return
	}

	// get the conn slice.
	userConnections := i.byUserId[wc.UserId]
	// get the last connection.
	last := userConnections[len(userConnections)-1]
	// set the slot that we are trying to remove to be the last connection.
	userConnections[userConnIndex] = last
	// remove the last connection from the slice.
	i.byUserId[wc.UserId] = userConnections[:len(userConnections)-1]
	// set the index of the connection that was moved to the new index.
	i.byConnection[last] = userConnIndex

	delete(i.byConnection, wc)
}

func (i *hubConnectionIndex) Has(wc *WebConn) bool {
	_, ok := i.byConnection[wc]
	return ok
}

func (i *hubConnectionIndex) ForUser(id string) []*WebConn {
	return i.byUserId[id]
}

func (i *hubConnectionIndex) All() map[*WebConn]int {
	return i.byConnection
}

// HubStop stops all the hubs.
func (s *Server) HubStop() {
	logrus.Info("stopping websocket hub connections")

	for _, hub := range s.hubs {
		hub.Stop()
	}
}

// Stop stops the hub.
func (h *Hub) Stop() {
	close(h.stop)
	<-h.didStop
}
