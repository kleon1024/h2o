package app

import (
	"errors"
	"h2o/pkg/model"
	"net/http"
)

func (a *App) GetUser(userId string) (*model.User, *model.AppError) {
	user, err := a.Srv().userService.GetUser(userId)
	if err != nil {
		var nfErr *store.ErrNotFound
		switch {
		case errors.As(err, &nfErr):
			return nil, model.NewAppError("GetUser", MissingAccountError, nil, nfErr.Error(), http.StatusNotFound)
		default:
			return nil, model.NewAppError("GetUser", "app.user.get_by_username.app_error", nil, err.Error(), http.StatusInternalServerError)
		}
	}

	return user, nil
}
