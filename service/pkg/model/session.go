package model

import (
	"encoding/json"
	"io"
)

const (
	SessionCookieToken            = "H2OAUTHTOKEN"
	SessionCookieUser             = "H2OUSERID"
	SessionCookieCsrf             = "H2OCSRF"
	SessionCacheSize              = 35000
	SessionPropPlatform           = "platform"
	SessionPropOs                 = "os"
	SessionPropBrowser            = "browser"
	SessionPropType               = "type"
	SessionPropUserAccessTokenId  = "user_access_token_id"
	SessionPropIsBot              = "is_bot"
	SessionPropIsBotValue         = "true"
	SessionTypeUserAccessToken    = "UserAccessToken"
	SessionTypeCloudKey           = "CloudKey"
	SessionTypeRemoteclusterToken = "RemoteClusterToken"
	SessionPropIsGuest            = "is_guest"
	SessionActivityTimeout        = 1000 * 60 * 5 // 5 minutes
	SessionUserAccessTokenExpiry  = 100 * 365     // 100 years
)

type StringMap map[string]string

type Session struct {
	Id             string    `json:"id"`
	Token          string    `json:"token"`
	CreateAt       int64     `json:"create_at"`
	ExpiresAt      int64     `json:"expires_at"`
	LastActivityAt int64     `json:"last_activity_at"`
	UserId         string    `json:"user_id"`
	DeviceId       string    `json:"device_id"`
	IsOAuth        bool      `json:"is_oauth"`
	Props          StringMap `json:"props"`
	Local          bool      `gorm:"-" json:"local"`
}

// Returns true if the session is unrestricted, which should grant it
// with all permissions. This is used for local mode sessions
func (s *Session) IsUnrestricted() bool {
	return s.Local
}

func (s *Session) DeepCopy() *Session {
	copySession := *s

	if s.Props != nil {
		copySession.Props = CopyStringMap(s.Props)
	}

	return &copySession
}

func SessionFromJson(data io.Reader) *Session {
	var s *Session
	json.NewDecoder(data).Decode(&s)
	return s
}

func (s *Session) PreSave() {
	if s.Id == "" {
		s.Id = NewId()
	}

	if s.Token == "" {
		s.Token = NewId()
	}

	s.CreateAt = GetMillis()
	s.LastActivityAt = s.CreateAt

	if s.Props == nil {
		s.Props = make(map[string]string)
	}
}

func (s *Session) Sanitize() {
	s.Token = ""
}

func (s *Session) IsExpired() bool {

	if s.ExpiresAt <= 0 {
		return false
	}

	if GetMillis() > s.ExpiresAt {
		return true
	}

	return false
}

func (s *Session) AddProp(key string, value string) {

	if s.Props == nil {
		s.Props = make(map[string]string)
	}

	s.Props[key] = value
}

func SessionsToJson(o []*Session) string {
	b, err := json.Marshal(o)
	if err != nil {
		return "[]"
	}
	return string(b)
}

func SessionsFromJson(data io.Reader) []*Session {
	var o []*Session
	json.NewDecoder(data).Decode(&o)
	return o
}
