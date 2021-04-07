package dao

import (
	"time"

	"github.com/google/uuid"
)

const (
	TeamTypeNormal = "normal"
	TeamTypeUser   = "user"
)

type Team struct {
	ID   uuid.UUID `gorm:"type:char(36);primary_key"`
	Type string    `gorm:"column:type;not null"`
	Name string    `gorm:"name"`

	Members []User `gorm:"many2many:team_members"`
	Nodes   []Node `gorm:"foreignkey:TeamID"`

	CreatedBy     User      `gorm:"foreignkey:CreatedUserID"`
	CreatedUserID uuid.UUID `gorm:"type:char(36)"`
	UpdatedBy     User      `gorm:"foreignkey:UpdatedUserID"`
	UpdatedUserID uuid.UUID `gorm:"type:char(36)"`
	DeletedBy     User      `gorm:"foreignkey:DeletedUserID"`
	DeletedUserID uuid.UUID `gorm:"type:char(36)"`

	CreatedAt time.Time `gorm:"column:createdAt"`
	UpdatedAt time.Time `gorm:"column:updatedAt"`
	DeletedAt time.Time `gorm:"column:deletedAt"`
	Deleted   int       `gorm:"column:deleted"`
}
