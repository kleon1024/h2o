package app

import (
	"h2o/pkg/app/request"
	"h2o/pkg/model"
	"net/http"
)

func (a *App) AuthenticateUserForLogin(c *request.Context, id, loginId, password string) (user *model.User, err *model.AppError) {

	if user, err = a.GetUserForLogin(id, loginId); err != nil {
		return nil, err
	}

	return user, nil
}

func (a *App) GetUserForLogin(id, loginId string) (*model.User, *model.AppError) {
	// If we are given a userID then fail if we can't find a user with that ID
	if id != "" {
		user, err := a.GetUser(id)
		if err != nil {
			if err.Id != MissingAccountError {
				err.StatusCode = http.StatusInternalServerError
				return nil, err
			}
			err.StatusCode = http.StatusBadRequest
			return nil, err
		}
		return user, nil
	}

	// // Try to get the user by username/email
	// if user, err := a.Srv().Store.User().GetForLogin(loginId, enableUsername, enableEmail); err == nil {
	// 	return user, nil
	// }

	return nil, nil
}
