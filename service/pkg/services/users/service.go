package users

import (
	"h2o/pkg/model"
	"h2o/pkg/store"
	"sync"

	"github.com/eko/gocache/cache"
)

type UserService struct {
	store        store.UserStore
	sessionStore store.SessionStore
	sessionCache cache.Cache
	sessionPool  sync.Pool
	config       func() *model.Config
}
