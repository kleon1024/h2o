package dao

import (
	"github.com/google/uuid"
)

type TableBlock struct {
	ID        uuid.UUID `gorm:"type:char(36);primary_key"`
	Namespace string    `gorm:"column:namespace"`
	DSN       string    `gorm:"column:dsn"`
	External  bool      `gorm:"bool"`
	Columns   []Column  `gorm:"foreignkey:TableBlockID"`
}
