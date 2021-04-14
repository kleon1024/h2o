package dao

import (
	"fmt"
	"h2o/pkg/util/orm"
	"strings"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Table struct {
	ID       uuid.UUID `gorm:"column:id;type:char(36);primary_key;not null"`
	DSN      string    `gorm:"column:dsn;not null"`
	External bool      `gorm:"column:external;not null"`
	NodeID   uuid.UUID `gorm:"column:node_id;type:char(36);index;not null"`
}

func (u *Table) BeforeCreate(tx *gorm.DB) error {
	if u.ID != EmptyUUID {
		return nil
	}
	u.ID = uuid.New()

	return nil
}

func (u *Table) Save(db *gorm.DB) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		return tx.Save(u).Error
	})
}

func (u *Table) Columns(db *gorm.DB) (*[]Column, error) {
	columns := []Column{}
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		tx = tx.Model(&Column{})
		tx = tx.Where("deleted = 0")
		tx = tx.Where("table_id = ?", u.ID)
		return tx.Find(&columns).Error
	})
	return &columns, err
}

func (u *Table) CreateTable(db *gorm.DB, columns *[]Column) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		raw := fmt.Sprintf("CREATE TABLE IF NOT EXIST %v (", u.ID)
		for _, column := range *columns {
			typeString := ColumnTypeMap[column.Type]
			raw += fmt.Sprintf("%v %v NOT NULL", column.Name, typeString)
		}
		raw += "id INT PRIMARY KEY NOT NULL)"
		return tx.Raw(raw).Error
	})
}

func (u *Table) Exists(db *gorm.DB, uuidString string) error {
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

func (u *Table) Rows(db *gorm.DB, columns *[]string, offset int, limit int) (*[][]string, error) {
	retRows := [][]string{}
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		raw := fmt.Sprintf("SELECT %v FROM %v OFFSET %v LIMIT %v", strings.Join(*columns, ","), u.ID, offset, limit)
		rows, err := tx.Raw(raw).Rows()
		if err != nil {
			return err
		}
		ptrRow := make([]*string, len(*columns))
		defer rows.Close()
		for rows.Next() {
			rows.Scan(ptrRow)
			derefRow := make([]string, len(*columns))
			for i, r := range ptrRow {
				derefRow[i] = *r
			}
			retRows = append(retRows, derefRow)
		}
		return nil
	})
	return &retRows, err
}

func (u *Table) AddColumn(db *gorm.DB, column Column) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		err := tx.Save(&column).Error
		if err != nil {
			return err
		}
		typeString := ColumnTypeMap[column.Type]
		raw := fmt.Sprintf("ALTER TABLE %v ADD COLUMN %v %v", u.ID, column.ID.String(), typeString)
		return tx.Raw(raw).Error
	})
}

func (u *Table) Insert(db *gorm.DB, rows map[string]string) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		ids := make([]string, 0, len(rows))
		values := make([]string, 0, len(rows))
		for id, value := range rows {
			ids = append(ids, fmt.Sprintf("`%v`", id))
			values = append(values, fmt.Sprintf("'%v'", value))
		}
		raw := fmt.Sprintf("INSERT INTO %v (%v) VALUES (%v)", u.ID, strings.Join(ids, ","), strings.Join(values, ","))
		return tx.Raw(raw).Error
	})
}

func (u *Table) DropColumn(db *gorm.DB, column Column) error {
	return orm.WithTransaction(db, func(tx *gorm.DB) error {
		err := tx.Delete(&column).Error
		if err != nil {
			return err
		}
		raw := fmt.Sprintf("ALTER TABLE %v DROP COLUMN %v", u.ID, column.ID.String())
		return tx.Raw(raw).Error
	})
}
