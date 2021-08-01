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

	// TODO: Personal Access Token for Integration
	// var appErr *model.AppError
	// if session == nil || session.Id == "" {
	// 	session, appErr = a.createSessionForUserAccessToken(token)
	// 	if appErr != nil {
	// 		detailedError := ""
	// 		statusCode := http.StatusUnauthorized
	// 		if appErr.Id != "app.user_access_token.invalid_or_missing" {
	// 			detailedError = appErr.Error()
	// 			statusCode = appErr.StatusCode
	// 		} else {
	// 			logrus.WithError(appErr).Warn("Error while creating session for user access token")
	// 		}
	// 		return nil, model.NewAppError("GetSession", "api.context.invalid_token.error", map[string]interface{}{"Token": token, "Error": detailedError}, "", statusCode)

	// 	}
	// }

	if session.Id == "" || session.IsExpired() {
		return nil, model.NewAppError("GetSession", "api.context.invalid_token.error", map[string]interface{}{"Token": token, "Error": ""}, "session is either nil or expired", http.StatusUnauthorized)
	}

	// TODO: SessionIdleTimeout to relogin typically 30 days

	return session, nil
}
