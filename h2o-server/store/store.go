package store

import (
	"context"
	"h2o/model"
)

type Store interface {
	Session() SessionStore
	User() UserStore
	Role() RoleStore
}

type SessionStore interface {
	Get(ctx context.Context, token string) (*model.Session, error)
}

type UserStore interface {
	Save(user *model.User) (*model.User, error)
	Get(ctx context.Context, id string) (*model.User, error)
	GetForLogin(loginID string) (*model.User, error)
}

type RoleStore interface {
	Save(role *model.Role) (*model.Role, error)
	Get(roleID string) (*model.Role, error)
	GetAll() ([]*model.Role, error)
	GetByName(ctx context.Context, name string) (*model.Role, error)
	GetByNames(names []string) ([]*model.Role, error)
	Delete(roleID string) (*model.Role, error)
	PermanentDeleteAll() error
}

type SystemStore interface {
	Save(system *model.System) error
	SaveOrUpdate(system *model.System) error
	Update(system *model.System) error
	Get() (model.StringMap, error)
	GetByName(name string) (*model.System, error)
	PermanentDeleteByName(name string) (*model.System, error)
	InsertIfExists(system *model.System) (*model.System, error)
	SaveOrUpdateWithWarnMetricHandling(system *model.System) error
}
