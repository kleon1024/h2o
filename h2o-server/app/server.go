package app

import (
	"fmt"
	"h2o/config"
	"h2o/model"
	"h2o/services/users"
	"h2o/shared/mlog"
	"h2o/store"
	"h2o/store/sqlstore"
	"hash/maphash"
	"time"

	sentry "github.com/getsentry/sentry-go"
	"github.com/gin-gonic/gin"
	"github.com/pkg/errors"
	"gorm.io/gorm"
)

type Server struct {
	ServiceConfig *config.ServiceConfig
	Database      *gorm.DB

	Router *gin.Engine

	sqlStore *sqlstore.SqlStore
	Store    store.Store

	newStore func() (store.Store, error)

	configStore *config.Store

	hubs     []*Hub
	hashSeed maphash.Seed

	userService *users.UserService
}

func NewServer(options ...Option) (*Server, error) {
	var err error

	r := gin.Default()

	s := &Server{
		hashSeed: maphash.MakeSeed(),
		Router:   r,
	}

	for _, option := range options {
		if err := option(s); err != nil {
			return nil, fmt.Errorf("failed to apply option: %v", err)
		}
	}

	if s.configStore == nil {
		innerStore, err := config.NewFileStore("config.json")
		if err != nil {
			return nil, errors.Wrap(err, "failed to load config")
		}
		configStore, err := config.NewStoreFromBacking(innerStore, nil, false)
		if err != nil {
			return nil, errors.Wrap(err, "failed to load config")
		}

		s.configStore = configStore
	}

	if s.newStore == nil {
		s.newStore = func() (store.Store, error) {
			s.sqlStore = sqlstore.New(s.Config().SqlSettings)

			return nil, nil // TODO
		}
	}

	s.Store, err = s.newStore()
	if err != nil {
		return nil, errors.Wrap(err, "cannot create store")
	}

	return s, nil
}

func (s *Server) Shutdown() {
	mlog.Info("Stopping Server...")

	defer sentry.Flush(2 * time.Second)

	s.HubStop()
}

func (s *Server) Start() error {
	mlog.Info("Starting Server...")

	addr := *s.Config().ServiceSettings.ListenAddress

	if addr == "" {
		if *s.Config().ServiceSettings.ConnectionSecurity == model.ConnSecurityTls {
			addr = ":https"
		} else {
			addr = ":http"
		}
	}

	go s.Router.Run(addr)

	return nil
}
