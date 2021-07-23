package store

import "h2o/pkg/model"

type Store interface {
	Session() SessionStore
}

type SessionStore interface {
	Get(token string) (*model.Session, error)
}
