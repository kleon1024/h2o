package config

import (
	"h2o/pkg/model"
	"sync"
)

type Store struct {
	configLock sync.RWMutex
	config     *model.Config
}

// Get fetches the current, cached configuration.
func (s *Store) Get() *model.Config {
	s.configLock.RLock()
	defer s.configLock.RUnlock()
	return s.config
}
