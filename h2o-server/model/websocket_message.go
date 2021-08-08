package model

import (
	"encoding/json"
	"fmt"
)

const (
	WEBSOCKET_EVENT_HELLO               = "hello"
	WEBSOCKET_EVENT_TYPING              = "typing"
	WEBSOCKET_EVENT_BLOCK_CREATED       = "block_created"
	WEBSOCKET_EVENT_BLOCK_UPDATED       = "block_updated"
	WEBSOCKET_EVENT_BLOCK_DELETED       = "block_deleted"
	WEBSOCKET_EVENT_BLOCK_MOVED         = "block_moved"
	WEBSOCKET_EVENT_BLOCK_UNREAD        = "block_unread"
	WEBSOCKET_EVENT_COLUMN_CREATED      = "column_created"
	WEBSOCKET_EVENT_COLUMN_UPDATED      = "column_updated"
	WEBSOCKET_EVENT_COLUMN_DELETED      = "column_deleted"
	WEBSOCKET_EVENT_ROW_CREATED         = "row_created"
	WEBSOCKET_EVENT_ROW_UPDATED         = "row_updated"
	WEBSOCKET_EVENT_ROW_DELETED         = "row_deleted"
	WEBSOCKET_EVENT_NODE_CONVERTED      = "node_converted"
	WEBSOCKET_EVENT_NODE_CREATED        = "node_created"
	WEBSOCKET_EVENT_NODE_DELETED        = "node_deleted"
	WEBSOCKET_EVENT_NODE_RESTORED       = "node_restored"
	WEBSOCKET_EVENT_NODE_UPDATED        = "node_updated"
	WEBSOCKET_EVENT_NODE_MEMBER_UPDATED = "node_member_updated"
	WEBSOCKET_EVENT_RESPONSE            = "response"
)

type WebSocketMessage interface {
	IsValid() bool
	EventType() string
}

type WebsocketBroadcast struct {
	UserId string `json:"user_id"`
	NodeId string `json:"node_id"`
	TeamId string `json:"team_id"`
}

type precomputedWebSocketEventJSON struct {
	Event     json.RawMessage
	Data      json.RawMessage
	Broadcast json.RawMessage
}

// webSocketEventJSON mirrors WebSocketEvent to make some of its unexported fields serializable
type webSocketEventJSON struct {
	Event     string                 `json:"event"`
	Data      map[string]interface{} `json:"data"`
	Broadcast *WebsocketBroadcast    `json:"broadcast"`
	Sequence  int64                  `json:"seq"`
}

type WebSocketEvent struct {
	Event           string                 // Deprecated: use EventType()
	Data            map[string]interface{} // Deprecated: use GetData()
	Broadcast       *WebsocketBroadcast    // Deprecated: use GetBroadcast()
	Sequence        int64                  // Deprecated: use GetSequence()
	precomputedJSON *precomputedWebSocketEventJSON
}

// PrecomputeJSON precomputes and stores the serialized JSON for all fields other than Sequence.
// This makes ToJson much more efficient when sending the same event to multiple connections.
func (ev *WebSocketEvent) PrecomputeJSON() *WebSocketEvent {
	copy := ev.Copy()
	event, _ := json.Marshal(copy.Event)
	data, _ := json.Marshal(copy.Data)
	broadcast, _ := json.Marshal(copy.Broadcast)
	copy.precomputedJSON = &precomputedWebSocketEventJSON{
		Event:     json.RawMessage(event),
		Data:      json.RawMessage(data),
		Broadcast: json.RawMessage(broadcast),
	}
	return copy
}

func (ev *WebSocketEvent) Add(key string, value interface{}) {
	ev.Data[key] = value
}

func NewWebSocketEvent(event string, teamId, nodeId, userId string) *WebSocketEvent {
	return &WebSocketEvent{
		Event: event,
		Data:  make(map[string]interface{}),
		Broadcast: &WebsocketBroadcast{
			TeamId: teamId, NodeId: nodeId, UserId: userId},
	}
}

func (ev *WebSocketEvent) Copy() *WebSocketEvent {
	return &WebSocketEvent{
		Event:     ev.Event,
		Data:      ev.Data,
		Broadcast: ev.Broadcast,
		Sequence:  ev.Sequence,
	}
}

func (ev *WebSocketEvent) IsValid() bool {
	return ev.Event != ""
}

func (ev *WebSocketEvent) EventType() string {
	return ev.Event
}

type WebSocketResponse struct {
	Status   string                 `json:"status"`
	SeqReply int64                  `json:"seq_reply,omitempty"`
	Data     map[string]interface{} `json:"data,omitempty"`
}

func (r *WebSocketResponse) Add(key string, value interface{}) {
	r.Data[key] = value
}

func NewWebSocketResponse(status string, seqReply int64, data map[string]interface{}) *WebSocketResponse {
	return &WebSocketResponse{
		Status:   status,
		SeqReply: seqReply,
		Data:     data,
	}
}

func (r *WebSocketResponse) IsValid() bool {
	return len(r.Status) != 0
}

func (r *WebSocketResponse) EventType() string {
	return WEBSOCKET_EVENT_RESPONSE
}

func (ev *WebSocketEvent) GetBroadcast() *WebsocketBroadcast {
	return ev.Broadcast
}

func (ev *WebSocketEvent) GetData() map[string]interface{} {
	return ev.Data
}

func (ev *WebSocketEvent) SetSequence(seq int64) *WebSocketEvent {
	copy := ev.Copy()
	copy.Sequence = seq
	return copy
}

// Encode encodes the event to the given encoder.
func (ev *WebSocketEvent) Encode(enc *json.Encoder) error {
	if ev.precomputedJSON != nil {
		return enc.Encode(json.RawMessage(
			fmt.Sprintf(`{"event": %s, "data": %s, "broadcast": %s, "seq": %d}`, ev.precomputedJSON.Event, ev.precomputedJSON.Data, ev.precomputedJSON.Broadcast, ev.Sequence),
		))
	}

	return enc.Encode(webSocketEventJSON{
		ev.Event,
		ev.Data,
		ev.Broadcast,
		ev.Sequence,
	})
}
