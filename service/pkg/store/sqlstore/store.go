package sqlstore

import (
	"h2o/pkg/config"
	"h2o/pkg/model"
	"h2o/pkg/store"
	"h2o/pkg/util/orm"
	"os"

	"github.com/sirupsen/logrus"
	"gorm.io/gorm"
)

const (
	ExitDBOpen = 101
)

type SqlStoreStores struct {
	session store.SessionStore
}

type SqlStore struct {
	db     *gorm.DB
	stores SqlStoreStores
}

func New(config *config.ServiceConfig) *SqlStore {
	store := &SqlStore{}

	db, err := orm.Connect(config)
	if err != nil {
		logrus.Fatal("Cannot connect to database")
		os.Exit(ExitDBOpen)
	}

	db.AutoMigrate(&model.Session{})

	store.db = db

	store.stores.session = newSqlSessionStore(store)

	return store
}
