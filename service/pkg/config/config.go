package config

import (
	"github.com/fsnotify/fsnotify"
	"github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

type ServiceConfig struct {
	// The config file
	ConfigFile string `mapstructure:"configFile"`
	// Debug
	Debug bool `mapstructure:"debug"`

	// The listening port of api
	ListeningPort int `mapstructure:"listeningPort"`

	DBConfig  DBConfig  `mapstructure:"db"`
	JWTConfig JWTConfig `mapstructure:"jwt"`
}

type DBConfig struct {
	Driver string `mapstructure:"driver"`
	DSN    string `mapstructure:"dsn"`
}

type JWTConfig struct {
	Secret                 string `mapstructure:"secret"`
	AccessTokenExpireHours int    `mapstructure:"accessTokenExpireHours"`
	RefreshTokenExpireDays int    `mapstructure:"refreshTokenExpireDays"`
	Issuer                 string `mapstructure:"issuer"`
}

func (cfg *ServiceConfig) Init(conf string) error {
	cfg.ConfigFile = conf

	v := viper.New()
	v.SetConfigFile(cfg.ConfigFile)

	err := cfg.load(v)
	if err != nil {
		logrus.WithField("configFile", conf).Warn("Cannot load config from file")
	}

	v.WatchConfig()
	v.OnConfigChange(func(fsnotify.Event) {
		cfg.load(v)
	})
	return nil
}

func (cfg *ServiceConfig) load(v *viper.Viper) error {
	if err := v.ReadInConfig(); err != nil {
		return err
	}
	v.Unmarshal(&cfg)
	logrus.Infof("Service config file %v loaded", cfg.ConfigFile)
	logrus.Debugf("Service config: %v", cfg)
	return nil
}
