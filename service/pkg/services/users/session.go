package users

import (
	"h2o/pkg/model"
)

func (us *UserService) GetSession(token string) (*model.Session, error) {
	var session = us.sessionPool.Get().(*model.Session)
	if sessionInterface, err := us.sessionCache.Get(token); err == nil {
		session = sessionInterface.(*model.Session)
	}

	if session.Id != "" {
		return session, nil
	}

	return us.sessionStore.Get(token)
}

func (us *UserService) AddSessionToCache(session *model.Session) {

}
