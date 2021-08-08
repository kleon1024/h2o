package app

import (
	"h2o/model"
	"net/http"
)

func (a *App) GetRolesByNames(names []string) ([]*model.Role, *model.AppError) {
	roles, nErr := a.Srv().Store.Role().GetByNames(names)
	if nErr != nil {
		return nil, model.NewAppError("GetRolesByNames", "app.role.get_by_names.app_error", nil, nErr.Error(), http.StatusInternalServerError)
	}

	// err := a.mergeChannelHigherScopedPermissions(roles)
	// if err != nil {
	// 	return nil, err
	// }

	return roles, nil
}
