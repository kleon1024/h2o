package sqlstore

import (
	"context"
	"h2o/model"
	"h2o/store"

	"github.com/pkg/errors"
)

type SqlUserStore struct {
	*SqlStore
}

func (us *SqlUserStore) ClearCaches() {}

func newSqlSUserStore(store *SqlStore) *SqlUserStore {
	us := &SqlUserStore{store}
	return us
}

func (us SqlUserStore) Save(user *model.User) (*model.User, error) {
	user.PreSave()
	if err := user.IsValid(); err != nil {
		return nil, err
	}

	if err := us.db.Save(user).Error; err != nil {
		return nil, errors.Wrapf(err, "failed to save User with userId=%s", user.Id)
	}

	return user, nil
}

func (us SqlUserStore) Get(ctx context.Context, id string) (*model.User, error) {
	users := []*model.User{}
	if err := us.db.Model(&model.User{}).Where("id = ?", id).Find(users).Error; err != nil {
		return nil, errors.Wrapf(err, "failed to get User with userId=%s", id)
	}
	if len(users) == 0 {
		return nil, store.NewErrNotFound("User", id)
	}
	if len(users) > 1 {
		return nil, errors.New("multiple users found")
	}
	return users[0], nil
}

func (us SqlUserStore) GetForLogin(loginId string) (*model.User, error) {
	users := []*model.User{}
	if err := us.db.Model(&model.User{}).Where("username = ? OR email = ?", loginId, loginId).Find(users).Error; err != nil {
		return nil, errors.Wrapf(err, "failed to get User with username=%s or email=%s", loginId)
	}
	if len(users) == 0 {
		return nil, store.NewErrNotFound("User", loginId)
	}

	if len(users) > 1 {
		return nil, errors.New("multiple users found")
	}
	return users[0], nil
}
