package dao

import (
	"h2o/pkg/util/orm"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
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
	Name     string    `gorm:"column:name;not null"`
	Email    string    `gorm:"column:email;not null"`
	Password string    `gorm:"column:password;not null"`

	CreatedAt time.Time `gorm:"column:createdAt;not null"`
	UpdatedAt time.Time `gorm:"column:updatedAt;not null"`
	DeletedAt time.Time `gorm:"column:deletedAt;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}

func (u *User) BeforeCreate(tx *gorm.DB) error {
	u.ID = uuid.New()
	if u.Type == UserTypeAnonymous {
		u.Name = u.ID.String()
	}
	u.Deleted = 0
	u.CreatedAt = time.Now().UTC()
	u.UpdatedAt = time.Now().UTC()
	u.DeletedAt = time.Now().UTC()

	return nil
}

func (u *User) Save(db *gorm.DB) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		return tx.Save(u).Error
	})
}
