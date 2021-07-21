package app

import (
	"flag"
	"fmt"
	"h2o/pkg/api/handler"
	"h2o/pkg/api/middleware"
	"h2o/pkg/app"
	"h2o/pkg/config"
	"os"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/pflag"
)

const BasePath = "/api/v1"

func NewApiServiceCommand() *cobra.Command {
	cfg := &ApiServiceConfig{}
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

type ApiServiceConfig struct {
	config.ServiceConfig
}

func (app *ApiServiceConfig) AddFlags(flags *pflag.FlagSet) {
	flags.BoolVarP(&app.Debug, "debug", "d", false, "Enable debug mode")
	flags.IntVarP(&app.ListeningPort, "listening-port", "p", 8080, "The listening port of the api service")
	flags.StringVar(&app.DBConfig.Driver, "driver", "sqlite", "The driver of database. Support sqlite3, mysql")
	flags.StringVar(&app.DBConfig.DSN, "dsn", "h2o.sqlite", "The database server name")
	flags.StringVarP(&app.ConfigFile, "config", "c", "/etc/h2o/config.yaml", "The config file of api service")
	flags.AddGoFlagSet(flag.CommandLine)
}

func run(cmd *cobra.Command, args []string, cfg *ApiServiceConfig) error {
	svc, err := app.NewServer(
		app.SetupLogging(cfg.Debug),
		app.Config(&cfg.ServiceConfig),
		app.ConfigLoadFile(cfg.ConfigFile),
		app.SetupDatabase(),
	)
	if err != nil {
		return err
	}

	app := app.New(app.ServiceConnector(svc))
	app.CreateHubs()

	logrus.Debug("Api service is running in debug mode")

	r := setupRouter(svc)
	r.Run(fmt.Sprintf("0.0.0.0:%v", cfg.ListeningPort))
	return nil
}

func setupRouter(svc *app.Server) *gin.Engine {
	r := gin.Default()
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	config.AllowHeaders = append(config.AllowHeaders, "authorization")
	r.Use(cors.New(config))

	basics := r.Group(BasePath + "")
	basics.Use(middleware.Translation())
	handler.RegisterBasics(basics, svc)

	tokens := r.Group(BasePath + "/tokens")
	tokens.Use(middleware.Translation())
	tokens.Use(middleware.JWT(svc, middleware.JWTSubjectRefreshToken, true))
	handler.RegisterTokens(tokens, svc)

	users := r.Group(BasePath + "/users")
	users.Use(middleware.Translation())
	users.Use(middleware.JWT(svc, middleware.JWTSubjectAccessToken, false))
	handler.RegisterUsers(users, svc)

	teams := r.Group(BasePath + "/teams")
	teams.Use(middleware.Translation())
	teams.Use(middleware.JWT(svc, middleware.JWTSubjectAccessToken, true))
	handler.RegisterTeams(teams, svc)

	nodes := r.Group(BasePath + "/nodes")
	nodes.Use(middleware.Translation())
	nodes.Use(middleware.JWT(svc, middleware.JWTSubjectAccessToken, true))
	handler.RegisterNodes(nodes, svc)

	blocks := r.Group(BasePath + "/blocks")
	blocks.Use(middleware.Translation())
	blocks.Use(middleware.JWT(svc, middleware.JWTSubjectAccessToken, true))
	handler.RegisterBlocks(blocks, svc)

	tables := r.Group(BasePath + "/tables")
	tables.Use(middleware.Translation())
	tables.Use(middleware.JWT(svc, middleware.JWTSubjectAccessToken, true))
	handler.RegisterTables(tables, svc)

	websocket := r.Group(BasePath + "/ws")
	handler.RegisterWebSocket(websocket, svc)

	return r
}
