package config

import (
	"github.com/fsnotify/fsnotify"
	"github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

type ServiceConfig struct {
	// The config file
	ConfigFile string `mapstructure:"configFile"`

	// The listening port of api
	ListeningPort int `mapstructure:"listeningPort"`

	DBConfig  DBConfig  `mapstructure:"db"`
	JWTConfig JWTConfig `mapstructure:"jwt"`
}

type DBConfig struct {
	Driver   string `mapstructure:"driver"`
	User     string `mapstructure:"user"`
	Password string `mapstructure:"password"`
	Host     string `mapstructure:"host"`
	Port     int    `mapstructure:"port"`
	Database string `mapstructure:"database"`
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

	cfg.load(v)
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
