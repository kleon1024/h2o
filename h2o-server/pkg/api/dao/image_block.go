package dao

import (
	"github.com/google/uuid"
)

type ImageBlock struct {
	ID       uuid.UUID `gorm:"type:char(36);primary_key"`
	Url      string    `gorm:"url"`
	External bool      `gorm:"external"`
}
