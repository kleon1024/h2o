package app

import (
	"errors"
	"h2o/app/request"
	"h2o/model"
	"h2o/services/users"
	"h2o/store"
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

func (a *App) CreateUserFromSignup(c *request.Context, user *model.User, redirect string) (*model.User, *model.AppError) {
	// if err := a.IsUserSignUpAllowed(); err != nil {
	// 	return nil, err
	// }

	user.EmailVerified = true

	ruser, err := a.CreateUser(c, user)
	if err != nil {
		return nil, err
	}

	// if err := a.Srv().EmailService.SendWelcomeEmail(ruser.Id, ruser.Email, ruser.EmailVerified, ruser.DisableWelcomeEmail, ruser.Locale, a.GetSiteURL(), redirect); err != nil {
	// 	mlog.Warn("Failed to send welcome email on create user from signup", mlog.Err(err))
	// }

	return ruser, nil
}

// CreateUser creates a user and sets several fields of the returned User struct to
// their zero values.
func (a *App) CreateUser(c *request.Context, user *model.User) (*model.User, *model.AppError) {
	return a.createUserOrGuest(c, user, false)
}

// CreateGuest creates a guest and sets several fields of the returned User struct to
// their zero values.
func (a *App) CreateGuest(c *request.Context, user *model.User) (*model.User, *model.AppError) {
	return a.createUserOrGuest(c, user, true)
}

func (a *App) createUserOrGuest(c *request.Context, user *model.User, guest bool) (*model.User, *model.AppError) {
	ruser, nErr := a.srv.userService.CreateUser(user, users.UserCreateOptions{Guest: guest})
	if nErr != nil {
		var appErr *model.AppError
		var invErr *store.ErrInvalidInput
		var nfErr *users.ErrInvalidPassword
		switch {
		case errors.As(nErr, &appErr):
			return nil, appErr
		case errors.Is(nErr, users.AcceptedDomainError):
			return nil, model.NewAppError("createUserOrGuest", "api.user.create_user.accepted_domain.app_error", nil, "", http.StatusBadRequest)
		case errors.As(nErr, &nfErr):
			return nil, model.NewAppError("createUserOrGuest", "api.user.check_user_password.invalid.app_error", nil, "", http.StatusBadRequest)
		case errors.Is(nErr, users.UserCountError):
			return nil, model.NewAppError("createUserOrGuest", "app.user.get_total_users_count.app_error", nil, nErr.Error(), http.StatusInternalServerError)
		case errors.As(nErr, &invErr):
			switch invErr.Field {
			case "email":
				return nil, model.NewAppError("createUserOrGuest", "app.user.save.email_exists.app_error", nil, invErr.Error(), http.StatusBadRequest)
			case "username":
				return nil, model.NewAppError("createUserOrGuest", "app.user.save.username_exists.app_error", nil, invErr.Error(), http.StatusBadRequest)
			default:
				return nil, model.NewAppError("createUserOrGuest", "app.user.save.existing.app_error", nil, invErr.Error(), http.StatusBadRequest)
			}
		default:
			return nil, model.NewAppError("createUserOrGuest", "app.user.save.app_error", nil, nErr.Error(), http.StatusInternalServerError)
		}
	}

	return ruser, nil
}
