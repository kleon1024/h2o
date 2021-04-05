package dao

import (
	"github.com/google/uuid"
)

type BlockRevision struct {
	UUID       uuid.UUID        `gorm:"type:char(36);primary_key"`
	Type       int              `gorm:"column:type;not null"`
	Revision   int              `gorm:"column:revision;not null"`
	Attributes []BlockAttribute `gorm:"foreignkey:BlockUUID"`
}
