package sqlstore

import (
	"context"
	"database/sql"
	"encoding/json"
	"h2o/model"
	"h2o/store"
	"strings"

	sq "github.com/Masterminds/squirrel"

	"github.com/pkg/errors"
)

const (
	MaxGroupChannelsForProfiles = 50
)

var (
	UserSearchTypeNamesNoFullName = []string{"Username", "Nickname"}
	UserSearchTypeNames           = []string{"Username", "FirstName", "LastName", "Nickname"}
	UserSearchTypeAllNoFullName   = []string{"Username", "Nickname", "Email"}
	UserSearchTypeAll             = []string{"Username", "FirstName", "LastName", "Nickname", "Email"}
)

type SqlUserStore struct {
	*SqlStore

	// usersQuery is a starting point for all queries that return one or more Users.
	usersQuery sq.SelectBuilder
}

func (us *SqlUserStore) ClearCaches() {}

func newSqlUserStore(sqlStore *SqlStore) *SqlUserStore {
	us := &SqlUserStore{SqlStore: sqlStore}
	// note: we are providing field names explicitly here to maintain order of columns (needed when using raw queries)
	us.usersQuery = us.getQueryBuilder().
		Select(
			"u.Id",
			"u.CreateAt",
			"u.UpdateAt",
			"u.DeleteAt",
			"u.Username",
			"u.Password",
			"u.AuthData",
			"u.AuthService",
			"u.Email",
			"u.EmailVerified",
			"u.Nickname",
			"u.FirstName",
			"u.LastName",
			"u.Position",
			"u.Roles",
			"u.AllowMarketing",
			"u.Props",
			"u.NotifyProps",
			"u.LastPasswordUpdate",
			"u.LastPictureUpdate",
			"u.FailedAttempts",
			"u.Locale",
			"u.Timezone",
			"u.MfaActive",
			"u.MfaSecret",
			"b.UserId IS NOT NULL AS IsBot",
			"COALESCE(b.Description, '') AS BotDescription",
			"COALESCE(b.LastIconUpdate, 0) AS BotLastIconUpdate",
			"u.RemoteId").
		From("Users u").
		LeftJoin("Bots b ON ( b.UserId = u.Id )")

	for _, db := range sqlStore.GetAllConns() {
		table := db.AddTableWithName(model.User{}, "Users").SetKeys(false, "Id")
		table.ColMap("Id").SetMaxSize(26)
		table.ColMap("Username").SetMaxSize(64).SetUnique(true)
		table.ColMap("Password").SetMaxSize(128)
		table.ColMap("AuthData").SetMaxSize(128).SetUnique(true)
		table.ColMap("AuthService").SetMaxSize(32)
		table.ColMap("Email").SetMaxSize(128).SetUnique(true)
		table.ColMap("Nickname").SetMaxSize(64)
		table.ColMap("FirstName").SetMaxSize(64)
		table.ColMap("LastName").SetMaxSize(64)
		table.ColMap("Roles").SetMaxSize(256)
		table.ColMap("Props").SetDataType(sqlStore.jsonDataType())
		table.ColMap("NotifyProps").SetDataType(sqlStore.jsonDataType())
		table.ColMap("Locale").SetMaxSize(5)
		table.ColMap("MfaSecret").SetMaxSize(128)
		table.ColMap("RemoteId").SetMaxSize(26)
		table.ColMap("Position").SetMaxSize(128)
		table.ColMap("Timezone").SetDataType(sqlStore.jsonDataType())
	}
	return us
}

func (us SqlUserStore) createIndexesIfNotExists() {
	us.CreateIndexIfNotExists("idx_users_update_at", "Users", "UpdateAt")
	us.CreateIndexIfNotExists("idx_users_create_at", "Users", "CreateAt")
	us.CreateIndexIfNotExists("idx_users_delete_at", "Users", "DeleteAt")

	if us.DriverName() == model.DatabaseDriverPostgres {
		us.CreateIndexIfNotExists("idx_users_email_lower_textpattern", "Users", "lower(Email) text_pattern_ops")
		us.CreateIndexIfNotExists("idx_users_username_lower_textpattern", "Users", "lower(Username) text_pattern_ops")
		us.CreateIndexIfNotExists("idx_users_nickname_lower_textpattern", "Users", "lower(Nickname) text_pattern_ops")
		us.CreateIndexIfNotExists("idx_users_firstname_lower_textpattern", "Users", "lower(FirstName) text_pattern_ops")
		us.CreateIndexIfNotExists("idx_users_lastname_lower_textpattern", "Users", "lower(LastName) text_pattern_ops")
	}

	us.CreateFullTextIndexIfNotExists("idx_users_all_txt", "Users", strings.Join(UserSearchTypeAll, ", "))
	us.CreateFullTextIndexIfNotExists("idx_users_all_no_full_name_txt", "Users", strings.Join(UserSearchTypeAllNoFullName, ", "))
	us.CreateFullTextIndexIfNotExists("idx_users_names_txt", "Users", strings.Join(UserSearchTypeNames, ", "))
	us.CreateFullTextIndexIfNotExists("idx_users_names_no_full_name_txt", "Users", strings.Join(UserSearchTypeNamesNoFullName, ", "))
}

func (us SqlUserStore) Save(user *model.User) (*model.User, error) {
	if user.Id != "" && !user.IsRemote() {
		return nil, store.NewErrInvalidInput("User", "id", user.Id)
	}

	user.PreSave()
	if err := user.IsValid(); err != nil {
		return nil, err
	}

	if err := us.GetMaster().Insert(user); err != nil {
		if IsUniqueConstraintError(err, []string{"Email", "users_email_key", "idx_users_email_unique"}) {
			return nil, store.NewErrInvalidInput("User", "email", user.Email)
		}
		if IsUniqueConstraintError(err, []string{"Username", "users_username_key", "idx_users_username_unique"}) {
			return nil, store.NewErrInvalidInput("User", "username", user.Username)
		}
		return nil, errors.Wrapf(err, "failed to save User with userId=%s", user.Id)
	}

	return user, nil
}

func (us SqlUserStore) Get(ctx context.Context, id string) (*model.User, error) {
	query := us.usersQuery.Where("Id = ?", id)
	queryString, args, err := query.ToSql()
	if err != nil {
		return nil, errors.Wrap(err, "users_get_tosql")
	}
	row := us.SqlStore.DBFromContext(ctx).Db.QueryRow(queryString, args...)

	var user model.User
	var props, notifyProps, timezone []byte
	err = row.Scan(
		&user.Id,
		&user.CreateAt,
		&user.UpdateAt,
		&user.DeleteAt,
		&user.Username,
		&user.Password,
		&user.AuthData,
		&user.AuthService,
		&user.Email,
		&user.EmailVerified,
		&user.Nickname,
		&user.FirstName,
		&user.LastName,
		&user.Position,
		&user.Roles,
		&user.AllowMarketing,
		&props,
		&notifyProps,
		&user.LastPasswordUpdate,
		&user.LastPictureUpdate,
		&user.FailedAttempts,
		&user.Locale,
		&timezone,
		&user.MfaActive,
		&user.MfaSecret,
		&user.IsBot,
		&user.BotDescription,
		&user.BotLastIconUpdate,
		&user.RemoteId)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, store.NewErrNotFound("User", id)
		}
		return nil, errors.Wrapf(err, "failed to get User with userId=%s", id)

	}
	if err = json.Unmarshal(props, &user.Props); err != nil {
		return nil, errors.Wrap(err, "failed to unmarshal user props")
	}
	if err = json.Unmarshal(notifyProps, &user.NotifyProps); err != nil {
		return nil, errors.Wrap(err, "failed to unmarshal user notify props")
	}
	if err = json.Unmarshal(timezone, &user.Timezone); err != nil {
		return nil, errors.Wrap(err, "failed to unmarshal user timezone")
	}

	return &user, nil
}

func (us SqlUserStore) GetForLogin(loginId string) (*model.User, error) {
	query := us.usersQuery
	query = query.Where("Username = lower(?) OR Email = lower(?)", loginId, loginId)

	queryString, args, err := query.ToSql()
	if err != nil {
		return nil, errors.Wrap(err, "get_for_login_tosql")
	}

	users := []*model.User{}
	if _, err := us.GetReplica().Select(&users, queryString, args...); err != nil {
		return nil, errors.Wrap(err, "failed to find Users")
	}

	if len(users) == 0 {
		return nil, errors.New("user not found")
	}

	if len(users) > 1 {
		return nil, errors.New("multiple users found")
	}

	return users[0], nil
}
