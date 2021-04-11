package dao

import (
	"fmt"
	"h2o/pkg/util/orm"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

const (
	BlockIdentifier = "block"
)

const (
	BlockTypeText           = "text"
	BlockTypeHeading1       = "heading1"
	BlockTypeHeading2       = "heading2"
	BlockTypeHeading3       = "heading3"
	BlockTypeHeading4       = "heading4"
	BlockTypeHeading5       = "heading5"
	BlockTypeHeading6       = "heading6"
	BlockTypeBulletedList   = "bulletedList"
	BlockTypeNumberedList   = "numberedList"
	BlockTypeCheckbox       = "checkbox"
	BlockTypeImage          = "image"
	BlockTypeTable          = "table"
	BlockTypeTableReference = "tableReference"
	BlockTypeBarChart       = "barChart"
	BlockTypeReferenceBlock = "referenceBlock"
	BlockTypeReferenceNode  = "referenceNode"
)

var BlockTypeMap = map[string]struct{}{
	BlockTypeText:           {},
	BlockTypeHeading1:       {},
	BlockTypeHeading2:       {},
	BlockTypeHeading3:       {},
	BlockTypeHeading4:       {},
	BlockTypeHeading5:       {},
	BlockTypeHeading6:       {},
	BlockTypeBulletedList:   {},
	BlockTypeNumberedList:   {},
	BlockTypeCheckbox:       {},
	BlockTypeImage:          {},
	BlockTypeTable:          {},
	BlockTypeTableReference: {},
	BlockTypeBarChart:       {},
	BlockTypeReferenceBlock: {},
	BlockTypeReferenceNode:  {},
}

type Block struct {
	ID         uuid.UUID       `gorm:"type:char(36);primary_key"`
	Type       string          `gorm:"column:type;not null"`
	Text       string          `gorm:"column:text;not null"`
	Revision   int             `gorm:"column:revision;not null"`
	Node       Node            `gorm:"foreignkey:NodeID"`
	NodeID     uuid.UUID       `gorm:"type:char(36)"`
	Revisions  []BlockRevision `gorm:"foreignKey:BlockID"`
	PreBlockID uuid.UUID       `gorm:"type:char(36)"`
	PreBlock   *Block          `gorm:"foreignKey:PreBlockID"`
	PosBlockID uuid.UUID       `gorm:"type:char(36)"`
	PosBlock   *Block          `gorm:"foreignKey:PosBlockID"`
	SubBlockID uuid.UUID       `gorm:"type:char(36)"`

	CreatedBy     User      `gorm:"foreignkey:CreatedUserID"`
	CreatedUserID uuid.UUID `gorm:"type:char(36)"`
	UpdatedBy     User      `gorm:"foreignkey:UpdatedUserID"`
	UpdatedUserID uuid.UUID `gorm:"type:char(36)"`
	DeletedBy     User      `gorm:"foreignkey:DeletedUserID"`
	DeletedUserID uuid.UUID `gorm:"type:char(36)"`

	ColumnRatio float32 `gorm:"column:ratio;not null"`
	IndentLevel int     `gorm:"column:indent_level;not null"`

	CreatedAt time.Time `gorm:"column:created_at;not null"`
	UpdatedAt time.Time `gorm:"column:updated_at;not null"`
	DeletedAt time.Time `gorm:"column:deleted_at;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}

func (u *Block) BeforeCreate(tx *gorm.DB) error {
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

func (u *Block) BeforeSave(tx *gorm.DB) error {
	u.UpdatedAt = time.Now().UTC()
	if u.Deleted == 1 {
		u.DeletedAt = time.Now().UTC()
	}
	return nil
}

func (u *Block) Save(db *gorm.DB, pre *Block, pos *Block) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		err := tx.Save(u).Error
		if err != nil {
			return err
		}
		if pre.ID != EmptyUUID {
			pre.PosBlockID = u.ID
			err = tx.Save(pre).Error
			if err != nil {
				return err
			}
		}
		if pos.ID != EmptyUUID {
			pos.PreBlockID = u.ID
			err = tx.Save(pre).Error
			if err != nil {
				return err
			}
		}
		return nil
	})
}

func (u *Block) Find(db *gorm.DB, offset int, limit int, wheres []orm.WhereCondition) (*[]Block, error) {
	var s []Block
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

func (u *Block) FindPosBlock(db *gorm.DB) (*Block, error) {
	var s []Block
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Model(u)
		tx = tx.Where("deleted = 0")
		return tx.Association("PosBlock").Find(&s)
	})
	if err != nil {
		return nil, err
	}
	if len(s) == 0 {
		return &Block{}, nil
	}
	return &s[0], nil
}

func (u *Block) FindPreBlock(db *gorm.DB) (*Block, error) {
	var s []Block
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Model(u)
		tx = tx.Where("deleted = 0")
		return tx.Association("PreBlock").Find(&s)
	})
	if err != nil {
		return nil, err
	}
	if len(s) == 0 {
		return &Block{}, nil
	}
	return &s[0], nil
}

func (u *Block) Exists(db *gorm.DB, uuidString string) error {
	uuidInstance, err := uuid.Parse(uuidString)
	if err != nil {
		return err
	}
	emptyUUID := uuid.UUID{}
	if uuidInstance == emptyUUID {
		return nil
	}
	u.ID = uuidInstance
	var count int64
	err = orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Model(u).Where(u).Where("deleted = 0")
		return tx.Count(&count).Error
	})
	if count == 0 {
		if err != nil {
			err = fmt.Errorf("%v;resource not exist", err)
		} else {
			err = fmt.Errorf("resource not exist")
		}
	}
	return err
}
