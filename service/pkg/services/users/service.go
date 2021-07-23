package users

import (
	"h2o/pkg/store"
	"sync"

	"github.com/eko/gocache/cache"
)

type UserService struct {
	sessionStore store.SessionStore
	sessionCache cache.Cache
	sessionPool  sync.Pool
}
