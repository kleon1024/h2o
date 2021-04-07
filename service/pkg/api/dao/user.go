package dao

import (
	"time"

	"github.com/google/uuid"
)

const (
	UserTypeAdmin     = "admin"
	UserTypeMember    = "member"
	UserTypeGuest     = "guest"
	UserTypeAnonymous = "anonymous"
)

type User struct {
	ID       uuid.UUID `gorm:"type:char(36);primary_key"`
	Type     string    `gorm:"column:type;not null"`
	Name     string    `gorm:"column:name;unique;not null"`
	Email    string    `gorm:"column:email;unique;not null"`
	Password string    `gorm:"column:password;not null"`

	CreatedAt time.Time `gorm:"column:createdAt;not null"`
	UpdatedAt time.Time `gorm:"column:updatedAt;not null"`
	DeletedAt time.Time `gorm:"column:deletedAt;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}
