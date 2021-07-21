package app

import (
	"fmt"
	"h2o/pkg/config"
	"h2o/pkg/services/users"
	"hash/maphash"

	"gorm.io/gorm"
)

type Server struct {
	Config   *config.ServiceConfig
	Database *gorm.DB

	hubs     []*Hub
	hashSeed maphash.Seed

	userService *users.UserService
}

func NewServer(options ...Option) (*Server, error) {

	s := &Server{
		hashSeed: maphash.MakeSeed(),
	}

	for _, option := range options {
		if err := option(s); err != nil {
			return nil, fmt.Errorf("failed to apply option: %v", err)
		}
	}

	return s, nil
}
