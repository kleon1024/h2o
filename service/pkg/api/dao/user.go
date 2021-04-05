package dao

import (
	"time"

	"github.com/google/uuid"
)

const (
	UserTypeAdmin     = 0
	UserTypeMember    = 1
	UserTypeGuest     = 2
	UserTypeAnonymous = 3
)

type User struct {
	UUID uuid.UUID `gorm:"type:char(36);primary_key"`
	Type int       `gorm:"column:type;not null"`

	CreatedAt time.Time `gorm:"column:createdAt;not null"`
	UpdatedAt time.Time `gorm:"column:updatedAt;not null"`
	DeletedAt time.Time `gorm:"column:deletedAt;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}
