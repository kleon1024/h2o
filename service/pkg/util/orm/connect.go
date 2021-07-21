package orm

import (
	"h2o/pkg/config"

	"gorm.io/driver/mysql"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func Connect(cfg *config.ServiceConfig) (*gorm.DB, error) {
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
		database = database.Set("gorm:table_options", " DEFAULT CHARACTER SET = utf8mb4 COLLATE utf8mb4_0900_ai_ci")
	}
	return database, nil
}
