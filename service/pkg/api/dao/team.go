package dao

import (
	"h2o/pkg/util/orm"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

const (
	TeamIdentifier = "team"
)

type Team struct {
	ID   uuid.UUID `gorm:"type:char(36);primary_key"`
	Name string    `gorm:"name;not null"`

	Members []User `gorm:"many2many:team_members"`
	Nodes   []Node `gorm:"foreignkey:TeamID"`

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

func (u *Team) BeforeCreate(tx *gorm.DB) error {
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
		tx = tx.Model(u)
		tx = tx.Where("deleted = 0")
		tx = tx.Offset(offset)
		tx = tx.Limit(limit)
		return tx.Association("Nodes").Find(&s)
	})
	if err != nil {
		return nil, err
	}
	return &s, nil
}

func (u *Team) Exists(db *gorm.DB) (bool, error) {
	var count int64
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Model(u).Where(u).Where("deleted = 0")
		return tx.Count(&count).Error
	})
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
