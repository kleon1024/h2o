package app

import (
	"fmt"
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/dao"
	"h2o/pkg/api/handler"
	"h2o/pkg/util/orm"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
)

const BasePath = "/api/v1"

func NewApiServiceCommand() *cobra.Command {
	cfg := &options.ApiServiceConfig{}
	cmd := &cobra.Command{
		Use:  "api",
		Long: "Provide apis for h2o",
		Run: func(cmd *cobra.Command, args []string) {
			if err := run(cmd, args, cfg); err != nil {
				logrus.Fatalf("%v", err)
				os.Exit(1)
			}
		},
	}

	cfg.AddFlags(cmd.Flags())
	return cmd
}

func run(cmd *cobra.Command, args []string, cfg *options.ApiServiceConfig) error {
	if cfg.Debug {
		logrus.SetLevel(logrus.DebugLevel)
	}

	logrus.Debug("Api service is running in debug mode")

	if err := cfg.Init(cfg.ConfigFile); err != nil {
		return err
	}

	db, err := orm.Connect(cfg)
	if err != nil {
		return err
	}
	db.AutoMigrate(dao.Models...)
	logrus.Infof("Successfully created a new db connection: %v", db)

	svc := options.NewApiService(cfg, db)

	r := setupRouter(svc)
	r.Run(fmt.Sprintf("0.0.0.0:%v", cfg.ListeningPort))
	return nil
}

func setupRouter(svc *options.ApiService) *gin.Engine {
	r := gin.Default()

	basics := r.Group("/")
	handler.RegisterBasics(basics, svc)

	return r
}
