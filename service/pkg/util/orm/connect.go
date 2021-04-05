package orm

import (
	"fmt"
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
	case "sqlite3":
		dialector = sqlite.Open(db.Database)
	case "mysql":
		address := fmt.Sprintf("%v:%v@tcp(%v:%v)/%v?charset=utf8&parseTime=true&loc=Local", db.User, db.Password, db.Host, db.Port, db.Database)
		dialector = mysql.Open(address)
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
