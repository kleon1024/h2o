package app

import (
	"h2o/config"

	"github.com/sirupsen/logrus"
)

type Option func(s *Server) error

func Config(cfg *config.ServiceConfig) Option {
	return func(s *Server) error {
		s.ServiceConfig = cfg
		return nil
	}
}

func ConfigLoadFile(configFile string) Option {
	return func(s *Server) error {
		if err := s.ServiceConfig.Init(configFile); err != nil {
			return err
		}
		return nil
	}
}

// ConfigStore applies the given config store, typically to replace the traditional sources with a memory store for testing.
func ConfigStore(configStore *config.Store) Option {
	return func(s *Server) error {
		s.configStore = configStore

		return nil
	}
}

// func RunEssentialJobs(s *Server) error {
// 	s.runEssentialJobs = true

// 	return nil
// }

// func JoinCluster(s *Server) error {
// 	s.joinCluster = true

// 	return nil
// }

// func StartMetrics(s *Server) error {
// 	s.startMetrics = true

// 	return nil
// }

// func StartSearchEngine(s *Server) error {
// 	s.startSearchEngine = true

// 	return nil
// }

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
		// db, err := orm.Connect(s.ServiceConfig)
		// if err != nil {
		// 	return err
		// }
		// db.AutoMigrate(dao.Models...)
		// logrus.Infof("Successfully created a new db connection: %v", db)
		// s.Database = db
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
