package dao

import (
	"github.com/google/uuid"
)

type BlockRevision struct {
	ID            uuid.UUID `gorm:"type:char(36);primary_key"`
	BlockID       uuid.UUID `gorm:"type:char(36)"`
	Type          string    `gorm:"column:type;not null"`
	Revision      int       `gorm:"column:revision;not null"`
	Attributes    string    `gorm:"column:attributes"`
	CreatedUserID uuid.UUID `gorm:"type:char(36)"`
}
