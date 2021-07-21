package main

import (
	"h2o/cmd/api/app"
	"os"

	"github.com/sirupsen/logrus"
)

// @title H2O Service
// @version 1.0
// @BasePath /api/v1

func main() {
	command := app.NewApiServiceCommand()

	if err := command.Execute(); err != nil {
		logrus.WithError(err)
		os.Exit(1)
	}
}
