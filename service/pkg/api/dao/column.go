package dao

import (
	"time"

	"github.com/google/uuid"
)

const (
	ColumnTypeAuto    = "auto"
	ColumnTypeString  = "string"
	ColumnTypeInteger = "integer"
	ColumnTypeDate    = "date"
)

type Column struct {
	ID           uuid.UUID  `gorm:"type:char(36);primary_key"`
	TableBlockID uuid.UUID  `gorm:"type:cahr(36);not null"`
	Table        TableBlock `gorm:"foreignkey:TableBlockID;not null"`

	CreatedAt time.Time `gorm:"column:created_at;not null"`
	UpdatedAt time.Time `gorm:"column:updated_at;not null"`
	DeletedAt time.Time `gorm:"column:deleted_at;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}
