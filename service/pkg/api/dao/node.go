package dao

import (
	"time"

	"github.com/google/uuid"
)

const (
	NodeTypeDirectory = "directory"
	NodeTypeChannel   = "channel"
	NodeTypeDocument  = "document"
	NodeTypeTable     = "table"
)

type Node struct {
	UUID      uuid.UUID `gorm:"type:char(36);primary_key"`
	Type      string    `gorm:"column:type;not null"`
	Namespace string    `gorm:"namespace"`
	Parent    *Node     `gorm:"foreignkey:ParentID"`
	ParentID  uuid.UUID `gorm:"type:char(36)"`
	Children  []Node    `gorm:"foreignkey:ParentID"`
	TeamID    uuid.UUID `gorm:"type:char(36)"`
	Team      Team      `gorm:"foreignkey:TeamID"`
	Blocks    []Block   `gorm:"foreignkey:NodeID"`

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