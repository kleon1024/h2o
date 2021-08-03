package model

import (
	"encoding/json"
)

const (
	DatabaseDriverMysql    = "mysql"
	DatabaseDriverPostgres = "postgres"

	ServiceSettingsDefaultSiteUrl = "http://localhost:8065"

	FakeSetting = "********************************"

	SqlSettingsDefaultDataSource = "postgres://mmuser:mmtest@localhost/mattermost_test?sslmode=disable&connect_timeout=10"
)

type Config struct {
	ServiceSettings   ServiceSettings
	SqlSettings       SqlSettings
	PrivacySettings   PrivacySettings
	RateLimitSettings RateLimitSettings
}

func (o *Config) Clone() *Config {
	buf, err := json.Marshal(o)
	if err != nil {
		panic(err)
	}
	var ret Config
	err = json.Unmarshal(buf, &ret)
	if err != nil {
		panic(err)
	}
	return &ret
}

type ServiceSettings struct {
	SiteURL               *string `access:"environment_web_server,authentication_saml,write_restrictable"`
	EnableDeveloper       *bool   `access:"environment_developer,write_restrictable,cloud_restrictable"`
	SessionCacheInMinutes *int    `access:"environment_session_lengths,write_restrictable,cloud_restrictable"`
}

func (s *ServiceSettings) SetDefaults(isUpdate bool) {

	if s.SiteURL == nil {
		if s.EnableDeveloper != nil && *s.EnableDeveloper {
			s.SiteURL = NewString(ServiceSettingsDefaultSiteUrl)
		} else {
			s.SiteURL = NewString("")
		}
	}

	if s.EnableDeveloper == nil {
		s.EnableDeveloper = NewBool(false)
	}

	if s.SessionCacheInMinutes == nil {
		s.SessionCacheInMinutes = NewInt(10)
	}
}

type SqlSettings struct {
	DriverName               *string  `access:"environment_database,write_restrictable,cloud_restrictable"`
	DataSource               *string  `access:"environment_database,write_restrictable,cloud_restrictable"` // telemetry: none
	DataSourceReplicas       []string `access:"environment_database,write_restrictable,cloud_restrictable"`
	DataSourceSearchReplicas []string `access:"environment_database,write_restrictable,cloud_restrictable"`
	MaxIdleConns             *int     `access:"environment_database,write_restrictable,cloud_restrictable"`
}

func (s *SqlSettings) SetDefaults(isUpdate bool) {
	if s.DriverName == nil {
		s.DriverName = NewString(DatabaseDriverPostgres)
	}

	if s.DataSource == nil {
		s.DataSource = NewString(SqlSettingsDefaultDataSource)
	}

	if s.DataSourceReplicas == nil {
		s.DataSourceReplicas = []string{}
	}

	if s.DataSourceSearchReplicas == nil {
		s.DataSourceSearchReplicas = []string{}
	}
}

type RateLimitSettings struct {
	Enable           *bool  `access:"environment_rate_limiting,write_restrictable,cloud_restrictable"`
	PerSec           *int   `access:"environment_rate_limiting,write_restrictable,cloud_restrictable"`
	MaxBurst         *int   `access:"environment_rate_limiting,write_restrictable,cloud_restrictable"`
	MemoryStoreSize  *int   `access:"environment_rate_limiting,write_restrictable,cloud_restrictable"`
	VaryByRemoteAddr *bool  `access:"environment_rate_limiting,write_restrictable,cloud_restrictable"`
	VaryByUser       *bool  `access:"environment_rate_limiting,write_restrictable,cloud_restrictable"`
	VaryByHeader     string `access:"environment_rate_limiting,write_restrictable,cloud_restrictable"`
}

func (s *RateLimitSettings) SetDefaults() {
	if s.Enable == nil {
		s.Enable = NewBool(false)
	}

	if s.PerSec == nil {
		s.PerSec = NewInt(10)
	}

	if s.MaxBurst == nil {
		s.MaxBurst = NewInt(100)
	}

	if s.MemoryStoreSize == nil {
		s.MemoryStoreSize = NewInt(10000)
	}

	if s.VaryByRemoteAddr == nil {
		s.VaryByRemoteAddr = NewBool(true)
	}

	if s.VaryByUser == nil {
		s.VaryByUser = NewBool(false)
	}
}

type PrivacySettings struct {
	ShowEmailAddress *bool `access:"site_users_and_teams"`
	ShowFullName     *bool `access:"site_users_and_teams"`
}

func (s *PrivacySettings) setDefaults() {
	if s.ShowEmailAddress == nil {
		s.ShowEmailAddress = NewBool(true)
	}

	if s.ShowFullName == nil {
		s.ShowFullName = NewBool(true)
	}
}

// isUpdate detects a pre-existing config based on whether SiteURL has been changed
func (o *Config) isUpdate() bool {
	return o.ServiceSettings.SiteURL != nil
}

func (o *Config) SetDefaults() {
	isUpdate := o.isUpdate()

	o.SqlSettings.SetDefaults(isUpdate)
	o.PrivacySettings.setDefaults()
	o.RateLimitSettings.SetDefaults()
}

func (o *Config) IsValid() *AppError {
	return nil
}
