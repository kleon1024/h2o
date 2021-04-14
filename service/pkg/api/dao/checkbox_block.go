package dao

import (
	"github.com/google/uuid"
)

type CheckboxBlock struct {
	ID      uuid.UUID `gorm:"type:char(36);primary_key"`
	Checked bool      `gorm:"column:checked"`
}
