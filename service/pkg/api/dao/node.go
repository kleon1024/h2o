package dao

import (
	"time"

	"github.com/google/uuid"
)

const (
	NodeTypeDirectory   = 0
	NodeTypeTextChannel = 1
	NodeTypeDocument    = 10
	NodeTypeTable       = 20
)

type Node struct {
	UUID       uuid.UUID `gorm:"type:char(36);primary_key"`
	Type       int       `gorm:"column:type;not null"`
	Namespace  string    `gorm:"namespace"`
	Parent     *Node     `gorm:"foreignkey:ParentUUID"`
	ParentUUID uuid.UUID `gorm:"type:char(36)"`
	Children   []Node    `gorm:"foreignkey:ParentUUID"`

	Members []User `gorm:"many2many:node_members"`

	CreatedBy     User      `gorm:"foreignkey:CreatedByUUID"`
	CreatedByUUID uuid.UUID `gorm:"type:char(36)"`
	UpdatedBy     User      `gorm:"foreignkey:UpdatedByUUID"`
	UpdatedByUUID uuid.UUID `gorm:"type:char(36)"`
	DeletedBy     User      `gorm:"foreignkey:DeletedByUUID"`
	DeletedByUUID uuid.UUID `gorm:"type:char(36)"`

	CreatedAt time.Time `gorm:"column:createdAt"`
	UpdatedAt time.Time `gorm:"column:updatedAt"`
	DeletedAt time.Time `gorm:"column:deletedAt"`
	Deleted   int       `gorm:"column:deleted"`
}
