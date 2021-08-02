package model

import (
	"h2o/pkg/services/timezones"
	"strings"

	"golang.org/x/crypto/bcrypt"
)

const (
	Me                             = "me"
	UserNotifyAll                  = "all"
	UserNotifyHere                 = "here"
	UserNotifyMention              = "mention"
	UserNotifyNone                 = "none"
	DesktopNotifyProp              = "desktop"
	DesktopSoundNotifyProp         = "desktop_sound"
	MarkUnreadNotifyProp           = "mark_unread"
	PushNotifyProp                 = "push"
	PushStatusNotifyProp           = "push_status"
	EmailNotifyProp                = "email"
	ChannelMentionsNotifyProp      = "channel"
	CommentsNotifyProp             = "comments"
	MentionKeysNotifyProp          = "mention_keys"
	CommentsNotifyNever            = "never"
	CommentsNotifyRoot             = "root"
	CommentsNotifyAny              = "any"
	FirstNameNotifyProp            = "first_name"
	AutoResponderActiveNotifyProp  = "auto_responder_active"
	AutoResponderMessageNotifyProp = "auto_responder_message"

	DefaultLocale        = "en"
	UserAuthServiceEmail = "email"

	UserEmailMaxLength    = 128
	UserNicknameMaxRunes  = 64
	UserPositionMaxRunes  = 128
	UserFirstNameMaxRunes = 64
	UserLastNameMaxRunes  = 64
	UserAuthDataMaxLength = 128
	UserNameMaxLength     = 64
	UserNameMinLength     = 1
	UserPasswordMaxLength = 72
	UserLocaleMaxLength   = 5
	UserTimezoneMaxRunes  = 256
)

type User struct {
	Id                     string    `json:"id"`
	CreateAt               int64     `json:"create_at,omitempty"`
	UpdateAt               int64     `json:"update_at,omitempty"`
	DeleteAt               int64     `json:"delete_at"`
	Username               string    `json:"username"`
	Password               string    `json:"password,omitempty"`
	AuthData               *string   `json:"auth_data,omitempty"`
	AuthService            string    `json:"auth_service"`
	Email                  string    `json:"email"`
	EmailVerified          bool      `json:"email_verified,omitempty"`
	Nickname               string    `json:"nickname"`
	FirstName              string    `json:"first_name"`
	LastName               string    `json:"last_name"`
	Position               string    `json:"position"`
	Roles                  string    `json:"roles"`
	AllowMarketing         bool      `json:"allow_marketing,omitempty"`
	Props                  StringMap `json:"props,omitempty"`
	NotifyProps            StringMap `json:"notify_props,omitempty"`
	LastPasswordUpdate     int64     `json:"last_password_update,omitempty"`
	LastPictureUpdate      int64     `json:"last_picture_update,omitempty"`
	FailedAttempts         int       `json:"failed_attempts,omitempty"`
	Locale                 string    `json:"locale"`
	Timezone               StringMap `json:"timezone"`
	MfaActive              bool      `json:"mfa_active,omitempty"`
	MfaSecret              string    `json:"mfa_secret,omitempty"`
	LastActivityAt         int64     `gorm:"-" json:"last_activity_at,omitempty"`
	IsBot                  bool      `gorm:"-" json:"is_bot,omitempty"`
	BotDescription         string    `gorm:"-" json:"bot_description,omitempty"`
	BotLastIconUpdate      int64     `gorm:"-" json:"bot_last_icon_update,omitempty"`
	TermsOfServiceId       string    `gorm:"-" json:"terms_of_service_id,omitempty"`
	TermsOfServiceCreateAt int64     `gorm:"-" json:"terms_of_service_create_at,omitempty"`
	DisableWelcomeEmail    bool      `gorm:"-" json:"disable_welcome_email"`
}

func NormalizeUsername(username string) string {
	return strings.ToLower(username)
}

func NormalizeEmail(email string) string {
	return strings.ToLower(email)
}

// PreSave will set the Id and Username if missing.  It will also fill
// in the CreateAt, UpdateAt times.  It will also hash the password.  It should
// be run before saving the user to the db.
func (u *User) PreSave() {
	if u.Id == "" {
		u.Id = NewId()
	}

	if u.Username == "" {
		u.Username = NewId()
	}

	if u.AuthData != nil && *u.AuthData == "" {
		u.AuthData = nil
	}

	u.Username = SanitizeUnicode(u.Username)
	u.FirstName = SanitizeUnicode(u.FirstName)
	u.LastName = SanitizeUnicode(u.LastName)
	u.Nickname = SanitizeUnicode(u.Nickname)

	u.Username = NormalizeUsername(u.Username)
	u.Email = NormalizeEmail(u.Email)

	u.CreateAt = GetMillis()
	u.UpdateAt = u.CreateAt

	u.LastPasswordUpdate = u.CreateAt

	u.MfaActive = false

	if u.Locale == "" {
		u.Locale = DefaultLocale
	}

	if u.Props == nil {
		u.Props = make(map[string]string)
	}

	if u.NotifyProps == nil || len(u.NotifyProps) == 0 {
		u.SetDefaultNotifications()
	}

	if u.Timezone == nil {
		u.Timezone = timezones.DefaultUserTimezone()
	}

	if u.Password != "" {
		u.Password = HashPassword(u.Password)
	}
}

func (u *User) SetDefaultNotifications() {
	u.NotifyProps = make(map[string]string)
	u.NotifyProps[EmailNotifyProp] = "true"
	u.NotifyProps[PushNotifyProp] = UserNotifyMention
	u.NotifyProps[DesktopNotifyProp] = UserNotifyMention
	u.NotifyProps[DesktopSoundNotifyProp] = "true"
	u.NotifyProps[MentionKeysNotifyProp] = ""
	u.NotifyProps[ChannelMentionsNotifyProp] = "true"
	u.NotifyProps[PushStatusNotifyProp] = StatusAway
	u.NotifyProps[CommentsNotifyProp] = CommentsNotifyNever
	u.NotifyProps[FirstNameNotifyProp] = "false"
}

// HashPassword generates a hash using the bcrypt.GenerateFromPassword
func HashPassword(password string) string {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		panic(err)
	}

	return string(hash)
}
