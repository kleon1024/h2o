package dao

import (
	"time"

	"github.com/google/uuid"
)

const (
	BlockTypeText           = 0
	BlockTypeHeading1       = 1
	BlockTypeHeading2       = 2
	BlockTypeHeading3       = 3
	BlockTypeHeading4       = 4
	BlockTypeHeading5       = 5
	BlockTypeHeading6       = 6
	BlockTypeBulletedList   = 7
	BlockTypeNumberedList   = 8
	BlockTypeCheckBox       = 100
	BlockTypeImage          = 200
	BlockTypeTable          = 300
	BlockTypeTableReference = 301
	BlockTypeBarChart       = 400
	BlockTypeReferenceBlock = 1000
	BlockTypeReferenceNode  = 1001
)

type Block struct {
	ID         uuid.UUID       `gorm:"type:char(36);primary_key"`
	Type       int             `gorm:"column:type;not null"`
	Text       string          `gorm:"column:text;not null"`
	Revision   int             `gorm:"column:revision;not null"`
	Node       Node            `gorm:"foreignkey:NodeID"`
	NodeID     uuid.UUID       `gorm:"type:char(36)"`
	Revisions  []BlockRevision `gorm:"foreignKey:BlockID"`
	SubBlockID uuid.UUID       `gorm:"type:char(36)"`

	CreatedBy     User      `gorm:"foreignkey:CreatedUserID"`
	CreatedUserID uuid.UUID `gorm:"type:char(36)"`
	UpdatedBy     User      `gorm:"foreignkey:UpdatedUserID"`
	UpdatedUserID uuid.UUID `gorm:"type:char(36)"`
	DeletedBy     User      `gorm:"foreignkey:DeletedUserID"`
	DeletedUserID uuid.UUID `gorm:"type:char(36)"`

	ColumnRatio float32 `gorm:"columnRatio"`
	IndentLevel int     `gorm:"column:indentLevel"`

	CreatedAt time.Time `gorm:"column:createdAt"`
	UpdatedAt time.Time `gorm:"column:updatedAt"`
	DeletedAt time.Time `gorm:"column:deletedAt"`
	Deleted   int       `gorm:"column:deleted"`
}
