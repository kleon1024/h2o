package main

import (
	"h2o/cmd/api/app"
	"os"

	"github.com/sirupsen/logrus"
)

func main() {
	command := app.NewApiServiceCommand()

	logrus.SetFormatter(&logrus.JSONFormatter{})

	if err := command.Execute(); err != nil {
		logrus.WithError(err)
		os.Exit(1)
	}
}
