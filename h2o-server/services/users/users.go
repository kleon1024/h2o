package users

import (
	"context"
	"h2o/model"
)

type UserCreateOptions struct {
	Guest      bool
	FromImport bool
}

func (us *UserService) GetUser(userID string) (*model.User, error) {
	return us.store.Get(context.Background(), userID)
}

// CreateUser creates a user
func (us *UserService) CreateUser(user *model.User, opts UserCreateOptions) (*model.User, error) {
	return us.createUser(user)
}

func (us *UserService) createUser(user *model.User) (*model.User, error) {
	user.MakeNonNil()

	if err := us.isPasswordValid(user.Password); user.AuthService == "" && err != nil {
		return nil, err
	}

	ruser, err := us.store.Save(user)
	if err != nil {
		return nil, err
	}
	// Determine whether to send the created user a welcome email
	ruser.DisableWelcomeEmail = user.DisableWelcomeEmail
	ruser.Sanitize(map[string]bool{})

	return ruser, nil
}
