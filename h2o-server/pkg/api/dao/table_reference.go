package dao

import (
	"github.com/google/uuid"
)

type TableReferenceBlock struct {
	ID        uuid.UUID `gorm:"type:char(36);primary_key"`
	Namespace string    `gorm:"column:namespace"`
	Rows      string    `gorm:"column:rows"`
	Columns   string    `gorm:"column:columns"`
}
