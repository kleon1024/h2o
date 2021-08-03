package users

import (
	"context"
	"h2o/model"
)

func (us *UserService) GetUser(userID string) (*model.User, error) {
	return us.store.Get(context.Background(), userID)
}
