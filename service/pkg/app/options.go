package app

import (
	"h2o/pkg/api/dao"
	"h2o/pkg/config"
	"h2o/pkg/util/orm"

	"github.com/sirupsen/logrus"
)

type Option func(s *Server) error

func Config(cfg *config.ServiceConfig) Option {
	return func(s *Server) error {
		s.Config = cfg
		return nil
	}
}

func ConfigLoadFile(configFile string) Option {
	return func(s *Server) error {
		if err := s.Config.Init(configFile); err != nil {
			return err
		}
		return nil
	}
}

func SetupLogging(debug bool) Option {
	return func(s *Server) error {
		logrus.SetFormatter(&logrus.JSONFormatter{})
		if debug {
			logrus.SetLevel(logrus.DebugLevel)
		}
		return nil
	}
}

func SetupDatabase() Option {
	return func(s *Server) error {
		db, err := orm.Connect(s.Config)
		if err != nil {
			return err
		}
		db.AutoMigrate(dao.Models...)
		logrus.Infof("Successfully created a new db connection: %v", db)
		s.Database = db
		return nil
	}
}

type AppOption func(a *App)
type AppOptionCreator func() []AppOption

func ServerConnector(s *Server) AppOption {
	return func(a *App) {
		a.srv = s
	}
}
