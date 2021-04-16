package dao

import (
	"fmt"
	"h2o/pkg/util/orm"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
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
		err := tx.Save(u).Error
		if err != nil {
			return err
		}
		raw := fmt.Sprintf("CREATE TABLE IF NOT EXISTS `%v` (", u.ID)
		raw += "`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL) DEFAULT CHARACTER SET = utf8mb4 COLLATE utf8mb4_0900_ai_ci"
		return tx.Exec(raw).Error
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
		tx = tx.Model(u).Where(u)
		return tx.First(&u).Error
	})
	return err
}

func (u *Table) Rows(db *gorm.DB, columns *[]Column, offset int, limit int) (*[]map[string]string, error) {
	retRows := make([]map[string]string, 0, limit)
	err := orm.WithTransaction(db, func(tx *gorm.DB) error {
		columnNames := make([]string, 0, len(*columns))
		logrus.Debugf("%v", len(*columns))
		for _, column := range *columns {
			columnNames = append(columnNames, fmt.Sprintf("`%v`", column.ID))
		}
		raw := fmt.Sprintf("SELECT %v FROM `%v`", strings.Join(columnNames, ","), u.ID)
		if offset > 0 {
			raw += fmt.Sprintf(" OFFSET %v ", offset)
		}
		if limit <= 0 {
			limit = 1
		}
		raw += fmt.Sprintf(" LIMIT %v ", limit)
		rows, err := tx.Raw(raw).Rows()
		if err != nil {
			return err
		}
		values := make([]interface{}, len(*columns))
		for i, column := range *columns {
			switch column.Type {
			case ColumnTypeString:
				values[i] = ""
			case ColumnTypeInteger:
				values[i] = 0
			case ColumnTypeDate:
				values[i] = time.Now().UTC()
			default:
				values[i] = ""
			}
		}
		ptrs := make([]interface{}, len(*columns))
		for i := range *columns {
			ptrs[i] = &values[i]
		}
		defer rows.Close()
		for rows.Next() {
			rows.Scan(ptrs...)
			derefRow := make(map[string]string, len(*columns))
			for i, r := range values {
				derefRow[(*columns)[i].ID.String()] = fmt.Sprintf("%v", string(r.([]uint8)))
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
		defaultString := ""
		if column.Type != ColumnTypeString {
			defaultString = fmt.Sprintf(" DEFAULT '%v' ", column.DefaultValue)
		}
		raw := fmt.Sprintf("ALTER TABLE `%v` ADD COLUMN `%v` %v %v NOT NULL", u.ID, column.ID.String(), typeString, defaultString)
		return tx.Exec(raw).Error
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
		raw := fmt.Sprintf("INSERT INTO `%v` (%v) VALUES (%v)", u.ID, strings.Join(ids, ","), strings.Join(values, ","))
		return tx.Exec(raw).Error
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
