package model

import (
	"encoding/json"
)

const (
	ConnSecurityNone     = ""
	ConnSecurityPlain    = "PLAIN"
	ConnSecurityTls      = "TLS"
	ConnSecurityStarttls = "STARTTLS"

	DatabaseDriverMysql    = "mysql"
	DatabaseDriverPostgres = "postgres"

	PasswordMaximumLength = 64
	PasswordMinimumLength = 5

	ServiceSettingsDefaultSiteUrl          = "http://localhost:8065"
	ServiceSettingsDefaultListenAndAddress = ":8065"

	FakeSetting = "********************************"

	SqlSettingsDefaultDataSource = "postgres://mmuser:mmtest@localhost/mattermost_test?sslmode=disable&connect_timeout=10"
)

type Config struct {
	ServiceSettings   ServiceSettings
	SqlSettings       SqlSettings
	PrivacySettings   PrivacySettings
	RateLimitSettings RateLimitSettings
	PasswordSettings  PasswordSettings
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
	ListenAddress         *string `access:"environment_web_server,write_restrictable,cloud_restrictable"` // telemetry: none
	ConnectionSecurity    *string `access:"environment_web_server,write_restrictable,cloud_restrictable"`
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

	if s.ListenAddress == nil {
		s.ListenAddress = NewString(ServiceSettingsDefaultListenAndAddress)
	}

	if s.ConnectionSecurity == nil {
		s.ConnectionSecurity = NewString("")
	}

	if s.EnableDeveloper == nil {
		s.EnableDeveloper = NewBool(false)
	}

	if s.SessionCacheInMinutes == nil {
		s.SessionCacheInMinutes = NewInt(10)
	}
}

type ReplicaLagSettings struct {
	DataSource       *string `access:"environment,write_restrictable,cloud_restrictable"` // telemetry: none
	QueryAbsoluteLag *string `access:"environment,write_restrictable,cloud_restrictable"` // telemetry: none
	QueryTimeLag     *string `access:"environment,write_restrictable,cloud_restrictable"` // telemetry: none
}

type SqlSettings struct {
	DriverName                  *string               `access:"environment_database,write_restrictable,cloud_restrictable"`
	DataSource                  *string               `access:"environment_database,write_restrictable,cloud_restrictable"` // telemetry: none
	DataSourceReplicas          []string              `access:"environment_database,write_restrictable,cloud_restrictable"`
	DataSourceSearchReplicas    []string              `access:"environment_database,write_restrictable,cloud_restrictable"`
	MaxIdleConns                *int                  `access:"environment_database,write_restrictable,cloud_restrictable"`
	ConnMaxLifetimeMilliseconds *int                  `access:"environment_database,write_restrictable,cloud_restrictable"`
	ConnMaxIdleTimeMilliseconds *int                  `access:"environment_database,write_restrictable,cloud_restrictable"`
	MaxOpenConns                *int                  `access:"environment_database,write_restrictable,cloud_restrictable"`
	Trace                       *bool                 `access:"environment_database,write_restrictable,cloud_restrictable"`
	AtRestEncryptKey            *string               `access:"environment_database,write_restrictable,cloud_restrictable"` // telemetry: none
	QueryTimeout                *int                  `access:"environment_database,write_restrictable,cloud_restrictable"`
	DisableDatabaseSearch       *bool                 `access:"environment_database,write_restrictable,cloud_restrictable"`
	ReplicaLagSettings          []*ReplicaLagSettings `access:"environment_database,write_restrictable,cloud_restrictable"` // telemetry: none
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

	if isUpdate {
		// When updating an existing configuration, ensure an encryption key has been specified.
		if s.AtRestEncryptKey == nil || *s.AtRestEncryptKey == "" {
			s.AtRestEncryptKey = NewString(NewRandomString(32))
		}
	} else {
		// When generating a blank configuration, leave this key empty to be generated on server start.
		s.AtRestEncryptKey = NewString("")
	}

	if s.MaxIdleConns == nil {
		s.MaxIdleConns = NewInt(20)
	}

	if s.MaxOpenConns == nil {
		s.MaxOpenConns = NewInt(300)
	}

	if s.ConnMaxLifetimeMilliseconds == nil {
		s.ConnMaxLifetimeMilliseconds = NewInt(3600000)
	}

	if s.ConnMaxIdleTimeMilliseconds == nil {
		s.ConnMaxIdleTimeMilliseconds = NewInt(300000)
	}

	if s.Trace == nil {
		s.Trace = NewBool(false)
	}

	if s.QueryTimeout == nil {
		s.QueryTimeout = NewInt(30)
	}

	if s.DisableDatabaseSearch == nil {
		s.DisableDatabaseSearch = NewBool(false)
	}

	if s.ReplicaLagSettings == nil {
		s.ReplicaLagSettings = []*ReplicaLagSettings{}
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

type PasswordSettings struct {
	MinimumLength *int  `access:"authentication_password"`
	Lowercase     *bool `access:"authentication_password"`
	Number        *bool `access:"authentication_password"`
	Uppercase     *bool `access:"authentication_password"`
	Symbol        *bool `access:"authentication_password"`
}

func (s *PasswordSettings) SetDefaults() {
	if s.MinimumLength == nil {
		s.MinimumLength = NewInt(10)
	}

	if s.Lowercase == nil {
		s.Lowercase = NewBool(true)
	}

	if s.Number == nil {
		s.Number = NewBool(true)
	}

	if s.Uppercase == nil {
		s.Uppercase = NewBool(true)
	}

	if s.Symbol == nil {
		s.Symbol = NewBool(true)
	}
}

// isUpdate detects a pre-existing config based on whether SiteURL has been changed
func (o *Config) isUpdate() bool {
	return o.ServiceSettings.SiteURL != nil
}

func (o *Config) SetDefaults() {
	isUpdate := o.isUpdate()

	o.ServiceSettings.SetDefaults(isUpdate)
	o.SqlSettings.SetDefaults(isUpdate)
	o.PrivacySettings.setDefaults()
	o.RateLimitSettings.SetDefaults()
}

func (o *Config) IsValid() *AppError {
	return nil
}
