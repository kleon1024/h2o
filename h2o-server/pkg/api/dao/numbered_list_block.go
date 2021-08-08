package dao

import (
	"github.com/google/uuid"
)

type NumberedListBlock struct {
	ID     uuid.UUID `gorm:"type:char(36);primary_key"`
	Number int       `gorm:"column:number"`
}
