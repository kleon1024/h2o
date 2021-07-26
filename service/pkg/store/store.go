package store

import (
	"context"
	"h2o/pkg/model"
)

type Store interface {
	Session() SessionStore
}

type SessionStore interface {
	Get(token string) (*model.Session, error)
}

type UserStore interface {
	Get(ctx context.Context, id string) (*model.User, error)
}
