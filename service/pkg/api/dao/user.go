package dao

import (
	"h2o/pkg/util/orm"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

const (
	UserTypeAdmin     = "admin"
	UserTypeMember    = "member"
	UserTypeGuest     = "guest"
	UserTypeAnonymous = "anonymous"
)

type User struct {
	ID       uuid.UUID `gorm:"column:id;type:char(36);primary_key;not null"`
	Type     string    `gorm:"column:type;not null"`
	Name     string    `gorm:"column:name;not null"`
	Email    string    `gorm:"column:email;not null"`
	Password string    `gorm:"column:password;not null"`

	CreatedAt time.Time `gorm:"column:created_at;not null"`
	UpdatedAt time.Time `gorm:"column:updated_at;not null"`
	DeletedAt time.Time `gorm:"column:deleted_at;not null"`
	Deleted   int       `gorm:"column:deleted;not null"`
}

func (u *User) BeforeCreate(tx *gorm.DB) error {
	if u.ID != EmptyUUID {
		return nil
	}
	u.ID = uuid.New()
	if u.Type == UserTypeAnonymous {
		u.Name = u.ID.String()
	}
	u.Deleted = 0
	u.CreatedAt = time.Now().UTC()
	u.UpdatedAt = time.Now().UTC()
	u.DeletedAt = time.Now().UTC()

	return nil
}

func (u *User) BeforeSave(tx *gorm.DB) error {
	u.UpdatedAt = time.Now().UTC()
	if u.Deleted == 1 {
		u.DeletedAt = time.Now().UTC()
	}
	return nil
}

func (u *User) Save(db *gorm.DB) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		return tx.Save(u).Error
	})
}

func (u *User) Find(db *gorm.DB, offset int, limit int, wheres []orm.WhereCondition) (*[]User, error) {
	var s []User
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

func (u *User) FindTeams(db *gorm.DB, offset int, limit int) (*[]Team, error) {
	var s []Team
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Model(&Team{})
		tx = tx.Joins("join team_members on team_members.team_id = teams.id", u.ID)
		tx = tx.Where("teams.deleted = ?", 0)
		tx = tx.Where("team_members.user_id = ?", u.ID)
		tx = tx.Offset(offset)
		tx = tx.Limit(limit)
		return tx.Find(&s).Error
	})
	if err != nil {
		return nil, err
	}
	return &s, nil
}
