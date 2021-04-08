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

	CreatedAt time.Time `gorm:"column:createdAt;not null"`
	UpdatedAt time.Time `gorm:"column:updatedAt;not null"`
	DeletedAt time.Time `gorm:"column:deletedAt;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}