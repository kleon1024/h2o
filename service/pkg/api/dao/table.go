package dao

import (
	"time"

	"github.com/google/uuid"
)

type Table struct {
	ID      uuid.UUID `gorm:"type:char(36);primary_key"`
	Name    string    `gorm:"column:name"`
	DSN     string    `gorm:"column:"dsn"`
	Columns []Column  `gorm:"foreignkey:TableID"`
	NodeID  uuid.UUID `gorm:"type:char(36)"`
	Node    Node      `gorm:"foreignkey:NodeID"`

	CreatedAt time.Time `gorm:"column:createdAt;not null"`
	UpdatedAt time.Time `gorm:"column:updatedAt;not null"`
	DeletedAt time.Time `gorm:"column:deletedAt;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}
