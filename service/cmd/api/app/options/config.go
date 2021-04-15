package options

import (
	"flag"
	"h2o/pkg/config"

	"gorm.io/gorm"

	"github.com/spf13/pflag"
)

func NewApiService(
	cfg *ApiServiceConfig,
	db *gorm.DB,
) *ApiService {
	return &ApiService{
		Config:   cfg,
		Database: db,
	}
}

type ApiServiceConfig struct {
	config.ServiceConfig
	// Enable debug mode
	Debug bool
}

type ApiService struct {
	Config   *ApiServiceConfig
	Database *gorm.DB
}

func (app *ApiServiceConfig) AddFlags(flags *pflag.FlagSet) {
	flags.BoolVarP(&app.Debug, "debug", "d", false, "Enable debug mode")
	flags.IntVarP(&app.ListeningPort, "listening-port", "p", 8080, "The listening port of the api service")
	flags.StringVar(&app.DBConfig.Driver, "driver", "sqlite", "The driver of database. Support sqlite3, mysql")
	flags.StringVar(&app.DBConfig.DSN, "dsn", "h2o.sqlite", "The database server name")
	flags.StringVarP(&app.ConfigFile, "config", "c", "/etc/h2o/config.yaml", "The config file of api service")
	flags.AddGoFlagSet(flag.CommandLine)
}
