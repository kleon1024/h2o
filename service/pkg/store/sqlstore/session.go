package sqlstore

import (
	"fmt"
	"h2o/pkg/model"

	"github.com/pkg/errors"
)

type SqlSessionStore struct {
	*SqlStore
}

func NewSqlSessionStore(store *SqlStore) *SqlSessionStore {
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

func (s *SqlSessionStore) GetByToken(token string) (*model.Session, error) {
	var sessions []*model.Session

	if err := s.db.Model(&model.Session{}).Where("token = ?", token).Find(&sessions).Error; err != nil {
		return nil, errors.Wrapf(err, "failed to get Sessions by token=%s", token)
	} else if len(sessions) == 0 {
		return nil, fmt.Errorf("not found Session token: %s", token)
	}
	session := sessions[0]
	return session, nil
}
