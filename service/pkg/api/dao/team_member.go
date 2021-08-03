package dao

import (
	"h2o/util/orm"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type TeamMember struct {
	TeamID uuid.UUID `gorm:"column:team_id;type:char(36);primary_key;not null"`
	UserID uuid.UUID `gorm:"column:user_id;type:char(36);primary_key;not null"`

	CreatedAt time.Time `gorm:"column:created_at;not null"`
}

func (u *TeamMember) Save(db *gorm.DB) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		return tx.Save(u).Error
	})
}

func (u *TeamMember) Find(db *gorm.DB, offset int, limit int, wheres []orm.WhereCondition) (*[]TeamMember, error) {
	var s []TeamMember
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Where(u)
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
