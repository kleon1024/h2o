package handler

import (
	"fmt"
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/dao"
	"h2o/pkg/api/dto"
	"h2o/pkg/api/middleware"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

type Teams struct {
	Service *options.ApiService
}

func RegisterTeams(r *gin.RouterGroup, svc *options.ApiService) {
	h := Teams{svc}
	r.GET("", h.ListTeams)
	r.GET("/:teamID/nodes", h.ListTeamNodes)
	r.POST("/:teamID/nodes", h.CreateTeamNode)
}

// @id ListTeams
// @summary 获取团队列表
// @tags Team
// @produce json
// @param body body dto.Pagination true "body"
// @success 200 {object} middleware.Response{data=dto.ListTeamsOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/teams [GET]
func (h *Teams) ListTeams(c *gin.Context) {
	userValue, _ := c.Get(middleware.UserKey)
	user := userValue.(dao.User)

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

	middleware.Success(c, dto.ListTeamsOutput{
		Pagination: *p,
		Teams:      outputs,
	})
}

// @id ListTeamNodes
// @summary 获取团队节点列表
// @tags Team
// @produce json
// @param teamID path string true "teamID"
// @param body body dto.Pagination true "body"
// @success 200 {object} middleware.Response{data=dto.ListTeamNodesOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/teams/:teamID/nodes [GET]
func (h *Teams) ListTeamNodes(c *gin.Context) {
	// userValue, _ := c.Get(middleware.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.ListTeamNodesInputPath{}
	if err := path.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	query := &dto.Pagination{
		Offset: dto.DefaultOffset,
		Limit:  dto.DefaultLimit,
	}
	if err := query.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	teamID, _ := uuid.Parse(path.TeamID)
	team := dao.Team{
		ID: teamID,
	}
	logrus.WithField("teamID", teamID).Debug()
	nodes, err := team.FindNodes(h.Service.Database, query.Offset, query.Limit)
	if err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	logrus.WithField("good", teamID).Debug()

	outputs := make([]dto.ListTeamNodesInstance, len(*nodes))
	for i, node := range *nodes {
		outputs[i].ID = node.ID.String()
		outputs[i].Name = node.Name
		outputs[i].Type = node.Type
		outputs[i].ParentID = node.ParentID.String()
	}

	middleware.Success(c, dto.ListTeamNodesOutput{
		Pagination: *query,
		Nodes:      outputs,
	})
}

// @id CreateTeamNode
// @summary 创建节点
// @tags Team
// @produce json
// @param teamID path string true "teamID"
// @success 200 {object} middleware.Response{data=dto.ListTeamNodesInstance} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @failure 404 {object} middleware.Response{data=interface{}} "not found"
// @router /api/v1/teams/:teamID/nodes [POST]
func (h *Teams) CreateTeamNode(c *gin.Context) {
	userValue, _ := c.Get(middleware.UserKey)
	user := userValue.(dao.User)
	// TODO: RABC

	path := &dto.ListTeamNodesInputPath{}
	if err := path.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	body := &dto.CreateTeamNodeInputBody{}
	if err := body.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	teamID, err := uuid.Parse(path.TeamID)
	if err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	team := dao.Team{
		ID: teamID,
	}
	if teamExists, err := team.Exists(h.Service.Database); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	} else if !teamExists {
		middleware.Error(c, http.StatusNotFound, err)
		return
	}

	logrus.WithField("type", body.Type).WithField("name", body.Name).Debug()
	if _, ok := dao.NodeTypeMap[body.Type]; !ok {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid node type"))
		return
	}

	node := dao.Node{
		Name:      body.Name,
		TeamID:    teamID,
		Type:      body.Type,
		CreatedBy: user,
		UpdatedBy: user,
	}
	if body.ParentID != "" {
		parent := dao.Node{}
		if err := parent.Exists(h.Service.Database, body.ParentID); err != nil {
			middleware.Error(c, http.StatusBadRequest, err)
			return
		}
		node.ParentID = parent.ID
	}

	if err := node.Save(h.Service.Database); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
	}

	middleware.Success(c, &dto.ListTeamNodesInstance{
		ID:       node.ID.String(),
		Name:     node.Name,
		Type:     node.Type,
		ParentID: node.ParentID.String(),
	})
}
