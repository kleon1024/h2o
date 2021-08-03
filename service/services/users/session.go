package users

import (
	"context"
	"h2o/model"
	"time"

	"github.com/eko/gocache/store"
)

func (us *UserService) GetSession(token string) (*model.Session, error) {
	var session *model.Session
	if sessionInterface, err := us.sessionCache.Get(token); err == nil {
		session = sessionInterface.(*model.Session)
		if session.Id != "" {
			return session, nil
		}
	}

	return us.sessionStore.Get(context.Background(), token)
}

func (us *UserService) AddSessionToCache(session *model.Session) {
	us.sessionCache.Set(session.Token, session, &store.Options{Expiration: time.Duration(int64(*us.config().ServiceSettings.SessionCacheInMinutes)) * time.Minute})
}
