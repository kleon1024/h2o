package dao

import (
	"time"

	"github.com/google/uuid"
)

type TableBlock struct {
	ID        uuid.UUID `gorm:"type:char(36);primary_key"`
	Namespace string    `gorm:"column:namespace"`
	DSN       string    `gorm:"column:dsn"`
	External  bool      `gorm:"bool"`
	Columns   []Column  `gorm:"foreignkey:TableBlockID"`

	CreatedAt time.Time `gorm:"column:createdAt;not null"`
	UpdatedAt time.Time `gorm:"column:updatedAt;not null"`
	DeletedAt time.Time `gorm:"column:deletedAt;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}
