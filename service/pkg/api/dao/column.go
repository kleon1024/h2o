package dao

import (
	"h2o/pkg/util/orm"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

const (
	ColumnTypeString  = "string"
	ColumnTypeInteger = "integer"
	ColumnTypeDate    = "date"
)

var ColumnTypeMap = map[string]string{
	ColumnTypeString:  "text",
	ColumnTypeInteger: "integer",
	ColumnTypeDate:    "datetime",
}

type Column struct {
	ID      uuid.UUID `gorm:"column:id;type:char(36);primary_key;not null"`
	TableID uuid.UUID `gorm:"column:table_id;type:char(36);index;not null"`
	Name    string    `gorm:"column:name;not null"`
	Type    string    `gorm:"column:type;not null"`
	Default string    `gorm:"column:default"`

	CreatedAt time.Time `gorm:"column:created_at;not null"`
	UpdatedAt time.Time `gorm:"column:updated_at;not null"`
	DeletedAt time.Time `gorm:"column:deleted_at;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}

func (u *Column) BeforeCreate(tx *gorm.DB) error {
	if u.ID != EmptyUUID {
		return nil
	}
	u.ID = uuid.New()

	return nil
}

func (u *Column) Save(db *gorm.DB) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		return tx.Save(u).Error
	})
}

func (u *Column) Exists(db *gorm.DB, uuidString string) error {
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
