package sqlstore

import (
	"context"
	"fmt"
	"h2o/pkg/model"

	"h2o/pkg/store"

	"github.com/pkg/errors"
)

type SqlSessionStore struct {
	*SqlStore
}

func newSqlSessionStore(store *SqlStore) *SqlSessionStore {
	us := &SqlSessionStore{store}
	return us
}

func (me SqlSessionStore) Save(session *model.Session) (*model.Session, error) {
	if session.Id != "" {
		return nil, fmt.Errorf("invalid input Session with id=%v", session.Id)
	}
	session.PreSave()

	if err := me.db.Save(session).Error; err != nil {
		return nil, errors.Wrapf(err, "failed to save Session with id=%v", session.Id)
	}

	return session, nil
}

func (s *SqlSessionStore) Get(ctx context.Context, sessionIdOrToken string) (*model.Session, error) {
	var sessions []*model.Session

	if err := s.db.Model(&model.Session{}).Where("token = ?", sessionIdOrToken).Find(&sessions).Error; err != nil {
		return nil, errors.Wrapf(err, "failed to get Sessions by sessionIdOrToken=%s", sessionIdOrToken)
	} else if len(sessions) == 0 {
		return nil, store.NewErrNotFound("Session", fmt.Sprintf("sessionIdOrToken=%s", sessionIdOrToken))
	}
	session := sessions[0]
	return session, nil
}
