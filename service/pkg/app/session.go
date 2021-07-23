package app

import (
	"h2o/pkg/model"
	"net/http"
)

func (a *App) GetSession(token string) (*model.Session, *model.AppError) {
	var session *model.Session
	if session, _ = a.srv.userService.GetSession(token); session != nil {
		if session.Token != token {
			return nil, model.NewAppError("GetSession", "api.context.invalid_token.error", map[string]interface{}{"token": token, "error": ""}, "session token is different from the one in DB", http.StatusUnauthorized)
		}

		if !session.IsExpired() {
			a.srv.userService.AddSessionToCache(session)
		}
	}

	// var appErr *model.AppError
	// if session == nil || session.Id == "" {
	// 	session, appErr = a.createSessionForUserAccessToken(token)
	// 	if appErr != nil {
	// 		// TODO
	// 	}
	// }

	return nil, nil
}
