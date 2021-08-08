package users

import (
	"h2o/model"
	"h2o/store"
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
