package commands

import (
	"encoding/json"
	"fmt"
	"h2o/model"
	"os"

	"github.com/spf13/cobra"
)

const CustomDefaultsEnvVar = "MM_CUSTOM_DEFAULTS_PATH"

func getConfigDSN(command *cobra.Command, env map[string]string) string {
	configDSN, _ := command.Flags().GetString("config")

	// Config not supplied in flag, check env
	if configDSN == "" {
		configDSN = env["MM_CONFIG"]
	}

	// Config not supplied in env or flag use default
	if configDSN == "" {
		configDSN = "config.json"
	}

	return configDSN
}

func loadCustomDefaults() (*model.Config, error) {
	customDefaultsPath := os.Getenv(CustomDefaultsEnvVar)
	if customDefaultsPath == "" {
		return nil, nil
	}

	file, err := os.Open(customDefaultsPath)
	if err != nil {
		return nil, fmt.Errorf("unable to open custom defaults file at %q: %w", customDefaultsPath, err)
	}
	defer file.Close()

	var customDefaults *model.Config
	err = json.NewDecoder(file).Decode(&customDefaults)
	if err != nil {
		return nil, fmt.Errorf("unable to decode custom defaults configuration: %w", err)
	}

	return customDefaults, nil
}
