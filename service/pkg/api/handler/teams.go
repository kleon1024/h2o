package handler

import (
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/dao"
	"h2o/pkg/api/dto"
	"h2o/pkg/api/middleware"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

type Teams struct {
	Service *options.ApiService
}

func RegisterTeams(r *gin.RouterGroup, svc *options.ApiService) {
	h := Teams{svc}
	r.GET("", h.ListTeams)
}

// @id ListTeams
// @summary 获取团队列表
// @tags Team
// @accept json
// @produce json
// @param body body dto.Pagination true "body"
// @success 200 {object} middleware.Response{data=dto.ListTeamsOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/teams [GET]
func (h *Teams) ListTeams(c *gin.Context) {
	userValue, _ := c.Get(middleware.UserKey)
	user := userValue.(dao.User)

	logrus.WithField("uid", user.ID.String()).Debug("")

	p := &dto.Pagination{
		Offset: dto.DefaultOffset,
		Limit:  dto.DefaultLimit,
	}
	if err := p.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	teams, err := user.FindTeams(h.Service.Database, p.Offset, p.Limit)
	if err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
	}

	outputs := make([]dto.ListTeamsInstance, len(*teams))
	for i, team := range *teams {
		outputs[i].ID = team.ID.String()
		outputs[i].Name = team.Name
	}

	logrus.WithField("teams", *teams).Debug()

	middleware.Success(c, dto.ListTeamsOutput{
		Pagination: *p,
		Teams:      outputs,
	})
}
