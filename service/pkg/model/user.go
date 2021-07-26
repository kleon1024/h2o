package model

type User struct {
	Id                     string    `json:"id"`
	CreateAt               int64     `json:"create_at,omitempty"`
	UpdateAt               int64     `json:"update_at,omitempty"`
	DeleteAt               int64     `json:"delete_at"`
	Username               string    `json:"username"`
	Password               string    `json:"password,omitempty"`
	Email                  string    `json:"email"`
	EmailVerified          bool      `json:"email_verified,omitempty"`
	Nickname               string    `json:"nickname"`
	FirstName              string    `json:"first_name"`
	LastName               string    `json:"last_name"`
	FailedAttempts         int       `json:"failed_attempts,omitempty"`
	Locale                 string    `json:"locale"`
	Timezone               StringMap `json:"timezone"`
	LastActivityAt         int64     `gorm:"-" json:"last_activity_at,omitempty"`
	IsBot                  bool      `gorm:"-" json:"is_bot,omitempty"`
	BotDescription         string    `gorm:"-" json:"bot_description,omitempty"`
	BotLastIconUpdate      int64     `gorm:"-" json:"bot_last_icon_update,omitempty"`
	TermsOfServiceId       string    `gorm:"-" json:"terms_of_service_id,omitempty"`
	TermsOfServiceCreateAt int64     `gorm:"-" json:"terms_of_service_create_at,omitempty"`
	DisableWelcomeEmail    bool      `gorm:"-" json:"disable_welcome_email"`
}
