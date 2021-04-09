package dao

import (
	"h2o/pkg/util/orm"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

const (
	NodeIdentifier = "node"
)
const (
	NodeTypeDirectory = "directory"
	NodeTypeChannel   = "channel"
	NodeTypeDocument  = "document"
	NodeTypeTable     = "table"
)

var NodeTypeMap = map[string]struct{}{
	NodeTypeDirectory: {},
	NodeTypeChannel:   {},
	NodeTypeDocument:  {},
	NodeTypeTable:     {},
}

type Node struct {
	ID       uuid.UUID `gorm:"type:char(36);primary_key"`
	Type     string    `gorm:"column:type;not null"`
	Name     string    `gorm:"name;not null"`
	Parent   *Node     `gorm:"foreignkey:ParentID"`
	ParentID uuid.UUID `gorm:"type:char(36)"`
	Children []Node    `gorm:"foreignkey:ParentID"`
	TeamID   uuid.UUID `gorm:"type:char(36)"`
	Team     Team      `gorm:"foreignkey:TeamID"`
	Blocks   []Block   `gorm:"foreignkey:NodeID"`

	CreatedBy     User      `gorm:"foreignkey:CreatedUserID"`
	CreatedUserID uuid.UUID `gorm:"type:char(36)"`
	UpdatedBy     User      `gorm:"foreignkey:UpdatedUserID"`
	UpdatedUserID uuid.UUID `gorm:"type:char(36)"`
	DeletedBy     User      `gorm:"foreignkey:DeletedUserID"`
	DeletedUserID uuid.UUID `gorm:"type:char(36)"`

	CreatedAt time.Time `gorm:"column:createdAt"`
	UpdatedAt time.Time `gorm:"column:updatedAt"`
	DeletedAt time.Time `gorm:"column:deletedAt"`
	Deleted   int       `gorm:"column:deleted"`
}

func (u *Node) BeforeCreate(tx *gorm.DB) error {
	empty := uuid.UUID{}
	if u.ID != empty {
		return nil
	}
	u.ID = uuid.New()
	u.Deleted = 0
	u.CreatedAt = time.Now().UTC()
	u.UpdatedAt = time.Now().UTC()
	u.DeletedAt = time.Now().UTC()

	return nil
}

func (u *Node) Save(db *gorm.DB) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		return tx.Save(u).Error
	})
}

func (u *Node) Find(db *gorm.DB, offset int, limit int, wheres []orm.WhereCondition) (*[]Node, error) {
	var s []Node
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		for _, where := range wheres {
			tx = tx.Where(where.Query, where.Args...)
		}
		tx = tx.Offset(offset)
		tx = tx.Limit(limit)
		return tx.Find(&s).Error
	})
	if err != nil {
		return nil, err
	}
	return &s, nil
}

func (u *Node) FindBlocks(db *gorm.DB, offset int, limit int) (*[]Block, error) {
	var s []Block
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Model(u)
		tx = tx.Where("deleted = ?", 0)
		tx = tx.Offset(offset)
		tx = tx.Limit(limit)
		return tx.Association("Blocks").Find(&s)
	})
	if err != nil {
		return nil, err
	}
	return &s, nil
}

func (u *Node) Exists(db *gorm.DB) (bool, error) {
	var count int64
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Where(u)
		return tx.Count(&count).Error
	})
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
