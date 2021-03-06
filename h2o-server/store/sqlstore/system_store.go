package sqlstore

import (
	"context"
	"database/sql"
	"fmt"
	"h2o/model"
	"h2o/store"
	"h2o/utils"
	"strconv"
	"strings"
	"time"

	sq "github.com/Masterminds/squirrel"
	"github.com/pkg/errors"
)

type SqlSystemStore struct {
	*SqlStore
}

func newSqlSystemStore(sqlStore *SqlStore) store.SystemStore {
	s := &SqlSystemStore{sqlStore}

	for _, db := range sqlStore.GetAllConns() {
		table := db.AddTableWithName(model.System{}, "Systems").SetKeys(false, "Name")
		table.ColMap("Name").SetMaxSize(64)
		table.ColMap("Value").SetMaxSize(1024)
	}

	return s
}

func (s SqlSystemStore) createIndexesIfNotExists() {
}

func (s SqlSystemStore) Save(system *model.System) error {
	if err := s.GetMaster().Insert(system); err != nil {
		return errors.Wrapf(err, "failed to save system property with name=%s", system.Name)
	}
	return nil
}

func (s SqlSystemStore) SaveOrUpdate(system *model.System) error {
	query := s.getQueryBuilder().
		Insert("Systems").
		Columns("Name", "Value").
		Values(system.Name, system.Value)

	if s.DriverName() == model.DatabaseDriverMysql {
		query = query.SuffixExpr(sq.Expr("ON DUPLICATE KEY UPDATE Value = ?", system.Value))
	} else {
		query = query.SuffixExpr(sq.Expr("ON CONFLICT (name) DO UPDATE SET Value = ?", system.Value))
	}

	queryString, args, err := query.ToSql()
	if err != nil {
		return errors.Wrap(err, "system_tosql")
	}

	if _, err := s.GetMaster().Exec(queryString, args...); err != nil {
		return errors.Wrap(err, "failed to upsert system property")
	}
	return nil
}

func (s SqlSystemStore) SaveOrUpdateWithWarnMetricHandling(system *model.System) error {
	if err := s.SaveOrUpdate(system); err != nil {
		return err
	}

	if strings.HasPrefix(system.Name, model.WarnMetricStatusStorePrefix) &&
		(system.Value == model.WarnMetricStatusRunonce || system.Value == model.WarnMetricStatusLimitReached) {
		if err := s.SaveOrUpdate(&model.System{
			Name:  model.SystemWarnMetricLastRunTimestampKey,
			Value: strconv.FormatInt(utils.MillisFromTime(time.Now()), 10),
		}); err != nil {
			return errors.Wrapf(err, "failed to save system property with name=%s", model.SystemWarnMetricLastRunTimestampKey)
		}
	}

	return nil
}

func (s SqlSystemStore) Update(system *model.System) error {
	if _, err := s.GetMaster().Update(system); err != nil {
		return errors.Wrapf(err, "failed to update system property with name=%s", system.Name)
	}
	return nil
}

func (s SqlSystemStore) Get() (model.StringMap, error) {
	var systems []model.System
	props := make(model.StringMap)
	if _, err := s.GetReplica().Select(&systems, "SELECT * FROM Systems"); err != nil {
		return nil, errors.Wrap(err, "failed to system properties")
	}
	for _, prop := range systems {
		props[prop.Name] = prop.Value
	}

	return props, nil
}

func (s SqlSystemStore) GetByName(name string) (*model.System, error) {
	var system model.System
	if err := s.GetMaster().SelectOne(&system, "SELECT * FROM Systems WHERE Name = :Name", map[string]interface{}{"Name": name}); err != nil {
		if err == sql.ErrNoRows {
			return nil, store.NewErrNotFound("System", fmt.Sprintf("name=%s", system.Name))
		}
		return nil, errors.Wrapf(err, "failed to get system property with name=%s", system.Name)
	}

	return &system, nil
}

func (s SqlSystemStore) PermanentDeleteByName(name string) (*model.System, error) {
	var system model.System
	if _, err := s.GetMaster().Exec("DELETE FROM Systems WHERE Name = :Name", map[string]interface{}{"Name": name}); err != nil {
		return nil, errors.Wrapf(err, "failed to permanent delete system property with name=%s", system.Name)
	}

	return &system, nil
}

// InsertIfExists inserts a given system value if it does not already exist. If a value
// already exists, it returns the old one, else returns the new one.
func (s SqlSystemStore) InsertIfExists(system *model.System) (*model.System, error) {
	tx, err := s.GetMaster().BeginTx(context.Background(), &sql.TxOptions{
		Isolation: sql.LevelSerializable,
	})
	if err != nil {
		return nil, errors.Wrap(err, "begin_transaction")
	}
	defer finalizeTransaction(tx)

	var origSystem model.System
	if err := tx.SelectOne(&origSystem, `SELECT * FROM Systems
		WHERE Name = :Name`,
		map[string]interface{}{"Name": system.Name}); err != nil && err != sql.ErrNoRows {
		return nil, errors.Wrapf(err, "failed to get system property with name=%s", system.Name)
	}

	if origSystem.Value != "" {
		// Already a value exists, return that.
		return &origSystem, nil
	}

	// Key does not exist, need to insert.
	if err := tx.Insert(system); err != nil {
		return nil, errors.Wrapf(err, "failed to save system property with name=%s", system.Name)
	}

	if err := tx.Commit(); err != nil {
		return nil, errors.Wrap(err, "commit_transaction")
	}
	return system, nil
}
