package store

import (
	"context"
	"h2o/model"
)

type Store interface {
	Session() SessionStore
	User() UserStore
}

type SessionStore interface {
	Get(ctx context.Context, token string) (*model.Session, error)
}

type UserStore interface {
	Get(ctx context.Context, id string) (*model.User, error)
	GetForLogin(loginID string) (*model.User, error)
}