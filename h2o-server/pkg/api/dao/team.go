package dao

import (
	"h2o/util/orm"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

const (
	TeamIdentifier = "team"
)

type Team struct {
	ID   uuid.UUID `gorm:"column:id;type:char(36);primary_key;not null"`
	Name string    `gorm:"column:name;not null"`

	CreatedUserID uuid.UUID `gorm:"column:created_user_id;type:char(36);not null"`
	UpdatedUserID uuid.UUID `gorm:"column:updated_user_id;type:char(36);not null"`
	DeletedUserID uuid.UUID `gorm:"column:deleted_user_id;type:char(36);not null"`

	CreatedAt time.Time `gorm:"column:created_at;not null"`
	UpdatedAt time.Time `gorm:"column:updated_at;not null"`
	DeletedAt time.Time `gorm:"column:deleted_at;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}

func (u *Team) BeforeCreate(tx *gorm.DB) error {
	if u.ID != EmptyUUID {
		return nil
	}
	u.ID = uuid.New()
	u.Deleted = 0
	u.CreatedAt = time.Now().UTC()
	u.UpdatedAt = time.Now().UTC()
	u.DeletedAt = time.Now().UTC()

	return nil
}

func (u *Team) BeforeSave(tx *gorm.DB) error {
	u.UpdatedAt = time.Now().UTC()
	if u.Deleted == 1 {
		u.DeletedAt = time.Now().UTC()
	}
	return nil
}

func (u *Team) Save(db *gorm.DB) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		return tx.Save(u).Error
	})
}

func (u *Team) Find(db *gorm.DB, offset int, limit int, wheres []orm.WhereCondition) (*[]Team, error) {
	var s []Team
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

func (u *Team) FindNodes(db *gorm.DB, offset int, limit int) (*[]Node, error) {
	var s []Node
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Model(&Node{})
		tx = tx.Where("deleted = ?", 0)
		tx = tx.Where("team_id = ?", u.ID)
		tx = tx.Offset(offset)
		tx = tx.Limit(limit)
		return tx.Find(&s).Error
	})
	if err != nil {
		return nil, err
	}
	return &s, nil
}

func (u *Team) Exists(db *gorm.DB, uuidString string) error {
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
