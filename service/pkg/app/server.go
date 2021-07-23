package app

import (
	"fmt"
	"h2o/pkg/config"
	"h2o/pkg/services/users"
	"h2o/pkg/store"
	"h2o/pkg/store/sqlstore"
	"hash/maphash"

	"github.com/pkg/errors"
	"gorm.io/gorm"
)

type Server struct {
	Config   *config.ServiceConfig
	Database *gorm.DB

	sqlStore *sqlstore.SqlStore
	Store    store.Store

	newStore func() (store.Store, error)

	hubs     []*Hub
	hashSeed maphash.Seed

	userService *users.UserService
}

func NewServer(options ...Option) (*Server, error) {
	var err error

	s := &Server{
		hashSeed: maphash.MakeSeed(),
	}

	for _, option := range options {
		if err := option(s); err != nil {
			return nil, fmt.Errorf("failed to apply option: %v", err)
		}
	}

	if s.newStore == nil {
		s.newStore = func() (store.Store, error) {
			s.sqlStore = sqlstore.New(s.Config)

			return nil, nil // TODO
		}
	}

	s.Store, err = s.newStore()
	if err != nil {
		return nil, errors.Wrap(err, "cannot create store")
	}

	return s, nil
}
