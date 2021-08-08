package dao

import (
	"h2o/util/orm"
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
	ID        uuid.UUID `gorm:"column:id;type:char(36);primary_key;not null"`
	Type      string    `gorm:"column:type;not null"`
	Name      string    `gorm:"column:name;not null"`
	TeamID    uuid.UUID `gorm:"column:team_id;type:char(36);index;not null"`
	PreNodeID uuid.UUID `gorm:"column:pre_node_id;type:char(36);not null"`
	PosNodeID uuid.UUID `gorm:"column:pos_node_id;type:char(36);not null"`
	Indent    int       `gorm:"column:indent;not null"`

	CreatedUserID uuid.UUID `gorm:"column:created_user_id;type:char(36);not null"`
	UpdatedUserID uuid.UUID `gorm:"column:updated_user_id;type:char(36);not null"`
	DeletedUserID uuid.UUID `gorm:"column:deleted_user_id;type:char(36);not null"`

	CreatedAt time.Time `gorm:"column:created_at;not null"`
	UpdatedAt time.Time `gorm:"column:updated_at;not null"`
	DeletedAt time.Time `gorm:"column:deleted_at;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}

func (u *Node) BeforeCreate(tx *gorm.DB) error {
	if u.ID != EmptyUUID {
		return nil
	}
	u.ID = uuid.New()

	return nil
}

func (u *Node) BeforeSave(tx *gorm.DB) error {
	u.UpdatedAt = time.Now().UTC()
	if u.Deleted == 1 {
		u.DeletedAt = time.Now().UTC()
	}
	return nil
}

func (u *Node) Save(db *gorm.DB, pre *Node, pos *Node) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		err := tx.Save(u).Error
		if err != nil {
			return err
		}
		if pre.ID != EmptyUUID {
			pre.PosNodeID = u.ID
			err = tx.Save(pre).Error
			if err != nil {
				return err
			}
		}
		if pos.ID != EmptyUUID {
			pos.PreNodeID = u.ID
			err = tx.Save(pos).Error
			if err != nil {
				return err
			}
		}
		return nil
	})
}

func (u *Node) SaveDelete(db *gorm.DB, pre *Node, pos *Node) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		err := tx.Save(u).Error
		if err != nil {
			return err
		}
		if pre.ID != EmptyUUID {
			pre.PosNodeID = u.PosNodeID
			err = tx.Save(pre).Error
			if err != nil {
				return err
			}
		}
		if pos.ID != EmptyUUID {
			pos.PreNodeID = u.PreNodeID
			err = tx.Save(pos).Error
			if err != nil {
				return err
			}
		}
		return nil
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
		tx = tx.Model(&Block{})
		tx = tx.Where("deleted = ?", 0)
		tx = tx.Where("node_id = ?", u.ID)
		tx = tx.Offset(offset)
		tx = tx.Limit(limit)
		return tx.Find(&s).Error
	})
	if err != nil {
		return nil, err
	}
	return &s, nil
}

func (u *Node) Exists(db *gorm.DB, uuidString string) error {
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

func (u *Node) Table(db *gorm.DB) (*Table, error) {
	table := Table{}
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Where("node_id = ?", u.ID)
		return tx.First(&table).Error
	})
	return &table, err
}
