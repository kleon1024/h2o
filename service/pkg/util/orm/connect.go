package orm

import (
	"h2o/cmd/api/app/options"

	"gorm.io/driver/mysql"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func Connect(cfg *options.ApiServiceConfig) (*gorm.DB, error) {
	var dialector gorm.Dialector
	db := cfg.DBConfig
	switch db.Driver {
	case "sqlite":
		dialector = sqlite.Open(db.DSN)
	case "mysql":
		dialector = mysql.Open(db.DSN)
	}

	logLevel := logger.Silent
	if cfg.Debug {
		logLevel = logger.Info
	}
	database, err := gorm.Open(dialector, &gorm.Config{
		Logger: logger.Default.LogMode(logLevel),
	})
	if err != nil {
		return nil, err
	}
	if db.Driver == "mysql" {
		database = database.Set("gorm:table_options", " CHARSET=utf8")
	}
	return database, nil
}
