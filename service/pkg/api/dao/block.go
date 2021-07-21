package dao

import (
	"encoding/json"
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
	ID          uuid.UUID `gorm:"column:id;type:char(36);primary_key"`
	Type        string    `gorm:"column:type;not null"`
	Text        string    `gorm:"column:text;not null"`
	Revision    int       `gorm:"column:revision;not null"`
	NodeID      uuid.UUID `gorm:"column:node_id;type:char(36);index;not null"`
	PreBlockID  uuid.UUID `gorm:"column:pre_block_id;type:char(36);not null"`
	PosBlockID  uuid.UUID `gorm:"column:pos_block_id;type:char(36);not null"`
	SubBlockID  uuid.UUID `gorm:"column:sub_block_id;type:char(36);not null"`
	ColumnRatio float32   `gorm:"column:ratio;not null"`
	IndentLevel int       `gorm:"column:indent_level;not null"`

	CreatedUserID uuid.UUID `gorm:"column:created_user_id;type:char(36);not null"`
	UpdatedUserID uuid.UUID `gorm:"column:updated_user_id;type:char(36);not null"`
	DeletedUserID uuid.UUID `gorm:"column:deleted_user_id;type:char(36);not null"`

	CreatedAt time.Time `gorm:"column:created_at;not null"`
	UpdatedAt time.Time `gorm:"column:updated_at;not null"`
	DeletedAt time.Time `gorm:"column:deleted_at;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}

func (o *Block) ToJson() string {
	b, _ := json.Marshal(o)
	return string(b)
}

func (u *Block) BeforeCreate(tx *gorm.DB) error {
	if u.ID != EmptyUUID {
		return nil
	}
	u.ID = uuid.New()

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
			err = tx.Save(pos).Error
			if err != nil {
				return err
			}
		}
		return nil
	})
}

func (u *Block) SaveDelete(db *gorm.DB, pre *Block, pos *Block) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		err := tx.Save(u).Error
		if err != nil {
			return err
		}
		if pre.ID != EmptyUUID {
			pre.PosBlockID = u.PosBlockID
			err = tx.Save(pre).Error
			if err != nil {
				return err
			}
		}
		if pos.ID != EmptyUUID {
			pos.PreBlockID = u.PreBlockID
			err = tx.Save(pos).Error
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
	if uuidInstance == EmptyUUID {
		return nil
	}
	u.ID = uuidInstance
	err = orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Model(u).Where(u).Where("deleted = 0")
		return tx.First(&u).Error
	})
	return err
}
