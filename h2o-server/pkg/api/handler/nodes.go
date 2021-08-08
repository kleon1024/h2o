package handler

import (
	"fmt"
	"h2o/api"
	"h2o/api/dao"
	"h2o/api/dto"
	"h2o/app"
	"h2o/config"
	"h2o/model"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

type Nodes struct {
	Service *app.Server
}

func RegisterNodes(r *gin.RouterGroup, svc *app.Server) {
	h := Nodes{svc}
	r.GET("/:nodeID/blocks", h.ListNodeBlocks)
	r.POST("/:nodeID/blocks", h.CreateNodeBlock)
	r.PUT("/:nodeID", h.UpdateNode)
	r.PATCH("/:nodeID", h.PatchNode)
	r.DELETE("/:nodeID", h.DeleteNode)
	r.GET("/:nodeID/table", h.GetNodeTable)
}

// @id ListNodeBlocks
// @summary 获取节点区块
// @tags Node
// @produce json
// @param nodeID path string true "nodeID"
// @param query query dto.Pagination true "query"
// @success 200 {object} middleware.Response{data=dto.BlockOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/nodes/:nodeID/blocks [GET]
func (h *Nodes) ListNodeBlocks(c *gin.Context) {
	// userValue, _ := c.Get(api.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.ListNodeBlocksInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	query := &dto.Pagination{
		Offset: dto.DefaultOffset,
		Limit:  dto.DefaultLimit,
	}
	if err := query.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	nodeID, _ := uuid.Parse(path.NodeID)
	node := dao.Node{
		ID: nodeID,
	}
	blocks, err := node.FindBlocks(h.Service.Database, query.Offset, query.Limit)
	if err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	outputs := make([]dto.BlockOutput, len(*blocks))
	for i, block := range *blocks {
		outputs[i].ID = block.ID.String()
		outputs[i].PreBlockID = block.PreBlockID.String()
		outputs[i].PosBlockID = block.PosBlockID.String()
		outputs[i].Text = block.Text
		outputs[i].Type = block.Type
		outputs[i].Revision = block.Revision
		outputs[i].AuthorID = block.UpdatedUserID.String()
		outputs[i].UpdatedAt = block.UpdatedAt.Format(config.DateFormatString)
	}

	api.Success(c, dto.ListNodeBlocksOutput{
		Pagination: *query,
		Blocks:     outputs,
	})
}

// @id CreateNodeBlock
// @summary 创建节点区块
// @tags Node
// @produce json
// @param nodeID path string true "nodeID"
// @success 200 {object} middleware.Response{data=dto.BlockOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @failure 404 {object} middleware.Response{data=interface{}} "not found"
// @router /api/v1/nodes/:nodeID/blocks [POST]
func (h *Nodes) CreateNodeBlock(c *gin.Context) {
	userValue, _ := c.Get(api.UserKey)
	user := userValue.(dao.User)
	// TODO: RABC

	path := &dto.ListNodeBlocksInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	body := &dto.CreateNodeBlockInputBody{}
	if err := body.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	logrus.WithField("event", "create_block").
		WithField("block_id", body.ID).
		WithField("pos_block_id", body.PosBlockID).
		WithField("pre_block_id", body.PreBlockID).Info()

	node := dao.Node{}
	if err := node.Exists(h.Service.Database, path.NodeID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	} else if node.ID == dao.EmptyUUID {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid node id"))
		return
	}

	preBlock := dao.Block{}
	if err := preBlock.Exists(h.Service.Database, body.PreBlockID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	posBlock := dao.Block{}
	if err := posBlock.Exists(h.Service.Database, body.PosBlockID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	if _, ok := dao.BlockTypeMap[body.Type]; !ok {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid block type"))
		return
	}

	block := &dao.Block{}
	if body.ID != "" {
		blockID, err := uuid.Parse(body.ID)
		if err != nil {
			api.Error(c, http.StatusBadRequest, err)
			return
		}
		if blockID == dao.EmptyUUID {
			api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid block id"))
			return
		}
		block.ID = blockID
	}

	block.Text = body.Text
	block.PreBlockID = preBlock.ID
	block.PosBlockID = posBlock.ID
	block.NodeID = node.ID
	block.Type = body.Type
	block.Revision = 0
	block.CreatedUserID = user.ID
	block.UpdatedUserID = user.ID
	block.Deleted = 0
	block.CreatedAt = time.Now().UTC()
	block.UpdatedAt = time.Now().UTC()
	block.DeletedAt = time.Now().UTC()

	if err := block.Save(h.Service.Database, &preBlock, &posBlock); err != nil {
		api.Error(c, http.StatusBadRequest, err)
	}

	message := model.NewWebSocketEvent(
		model.WEBSOCKET_EVENT_BLOCK_CREATED,
		node.TeamID.String(),
		block.NodeID.String(),
		block.ID.String(),
	)

	message.Add("block", block.ToJson())
	h.Service.Publish(message)

	api.Success(c, &dto.BlockOutput{
		ID:         block.ID.String(),
		PreBlockID: block.PreBlockID.String(),
		PosBlockID: block.PosBlockID.String(),
		Text:       block.Text,
		Type:       block.Type,
		Revision:   block.Revision,
		AuthorID:   block.UpdatedUserID.String(),
		UpdatedAt:  block.UpdatedAt.Format(config.DateFormatString),
	})
}

// @id UpdateNode
// @summary 全量更新节点
// @tags Node
// @produce json
// @param nodeID path string true "nodeID"
// @param body body dto.UpdateNodeInput true "body"
// @success 200 {object} middleware.Response{data=dto.NodeOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/nodes/:nodeID [PUT]
func (h *Nodes) UpdateNode(c *gin.Context) {
	userValue, _ := c.Get(api.UserKey)
	user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.NodeInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	body := &dto.UpdateNodeInputBody{}
	if err := body.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	node := dao.Node{}
	if err := node.Exists(h.Service.Database, path.NodeID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	} else if node.ID == dao.EmptyUUID {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid node id"))
		return
	}

	preNode := dao.Node{}
	if err := preNode.Exists(h.Service.Database, body.PreNodeID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	node.PreNodeID = preNode.ID

	posNode := dao.Node{}
	if err := posNode.Exists(h.Service.Database, body.PosNodeID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	node.PosNodeID = posNode.ID

	if _, ok := dao.NodeTypeMap[body.Type]; !ok {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid node type"))
		return
	}
	node.Type = body.Type
	node.Name = body.Name
	node.Indent = body.Indent

	team := dao.Team{}
	if err := team.Exists(h.Service.Database, body.TeamID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	} else if team.ID == dao.EmptyUUID {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid team id"))
		return
	}
	node.TeamID = team.ID

	node.UpdatedUserID = user.ID
	if err := node.Save(h.Service.Database, &preNode, &posNode); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	api.Success(c, &dto.NodeOutput{
		ID:        node.ID.String(),
		Name:      node.Name,
		Type:      node.Type,
		Indent:    node.Indent,
		TeamID:    node.TeamID.String(),
		PreNodeID: node.PreNodeID.String(),
		PosNodeID: node.PosNodeID.String(),
	})
}

// @id PatchNode
// @summary 增量更新节点
// @tags Node
// @produce json
// @param nodeID path string true "nodeID"
// @param body body dto.PatchNodeInput true "body"
// @success 200 {object} middleware.Response{data=dto.NodeOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/nodes/:nodeID [PATCH]
func (h *Nodes) PatchNode(c *gin.Context) {
	userValue, _ := c.Get(api.UserKey)
	user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.NodeInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	body := &dto.PatchNodeInputBody{
		Indent: -1,
	}
	if err := body.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	node := dao.Node{}
	if err := node.Exists(h.Service.Database, path.NodeID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	} else if node.ID == dao.EmptyUUID {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid node id"))
		return
	}

	if body.Type != "" {
		if _, ok := dao.NodeTypeMap[body.Type]; !ok {
			api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid node type"))
			return
		}
		node.Type = body.Type
	}

	if body.Name != "" {
		illegalChar := regexp.MustCompile(`[[/:;$@#%^*+=\|~]]`)
		spaceChar := regexp.MustCompile(`[\s]`)
		name := body.Name
		name = strings.TrimSpace(name)
		name = illegalChar.ReplaceAllString(name, "")
		name = spaceChar.ReplaceAllString(name, "-")
		if len(name) == 0 {
			api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid node name"))
			return
		}
		node.Name = name
	}

	if body.Indent != -1 {
		if body.Indent < 0 {
			api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid indent level"))
			return
		}
	}

	if body.TeamID != "" {
		team := dao.Team{}
		if err := team.Exists(h.Service.Database, body.TeamID); err != nil {
			api.Error(c, http.StatusBadRequest, err)
			return
		} else if team.ID == dao.EmptyUUID {
			api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid team id"))
			return
		}
		node.TeamID = team.ID
	}

	preNode := &dao.Node{}
	if body.PreNodeID != "" {
		if err := preNode.Exists(h.Service.Database, body.PreNodeID); err != nil {
			api.Error(c, http.StatusBadRequest, err)
			return
		}
		node.PreNodeID = preNode.ID
	}

	posNode := &dao.Node{}
	if body.PosNodeID != "" {
		if err := posNode.Exists(h.Service.Database, body.PosNodeID); err != nil {
			api.Error(c, http.StatusBadRequest, err)
			return
		}
		node.PosNodeID = posNode.ID
	}

	node.UpdatedUserID = user.ID
	if err := node.Save(h.Service.Database, preNode, posNode); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	api.Success(c, &dto.NodeOutput{
		ID:        node.ID.String(),
		Name:      node.Name,
		Type:      node.Type,
		Indent:    node.Indent,
		TeamID:    node.TeamID.String(),
		PreNodeID: node.PreNodeID.String(),
		PosNodeID: node.PosNodeID.String(),
	})
}

// @id DeleteNode
// @summary 删除节点
// @tags Node
// @produce json
// @param nodeID path string true "nodeID"
// @success 200 {object} middleware.Response{data=dto.NodeOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/nodes/:nodeID [DELETE]
func (h *Nodes) DeleteNode(c *gin.Context) {
	userValue, _ := c.Get(api.UserKey)
	user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.NodeInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	node := dao.Node{}
	if err := node.Exists(h.Service.Database, path.NodeID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	preNode := &dao.Node{}
	if err := node.Exists(h.Service.Database, node.PreNodeID.String()); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	posNode := &dao.Node{}
	if err := node.Exists(h.Service.Database, node.PosNodeID.String()); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	node.Deleted = 1
	node.UpdatedUserID = user.ID
	node.DeletedUserID = user.ID
	node.UpdatedAt = time.Now().UTC()
	node.DeletedAt = time.Now().UTC()

	if err := node.SaveDelete(h.Service.Database, preNode, posNode); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	api.Success(c, &dto.NodeOutput{
		ID:        node.ID.String(),
		Name:      node.Name,
		Type:      node.Type,
		Indent:    node.Indent,
		TeamID:    node.TeamID.String(),
		PreNodeID: node.PreNodeID.String(),
		PosNodeID: node.PosNodeID.String(),
	})
}

// @id GetNodeTable
// @summary GetNodeTable
// @tags Node
// @produce json
// @param nodeID path string true "nodeID"
// @success 200 {object} middleware.Response{data=dto.GetNodeTableOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/nodes/:nodeID/table [GET]
func (h *Nodes) GetNodeTable(c *gin.Context) {
	// userValue, _ := c.Get(api.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.NodeInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	node := dao.Node{}
	if err := node.Exists(h.Service.Database, path.NodeID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	table, err := node.Table(h.Service.Database)
	if err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	columns, err := table.Columns(h.Service.Database)
	if err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	outputs := make([]dto.Column, len(*columns))
	for i, c := range *columns {
		outputs[i].ID = c.ID.String()
		outputs[i].Name = c.Name
		outputs[i].Type = c.Type
		outputs[i].DefaultValue = c.DefaultValue
	}

	api.Success(c, &dto.GetNodeTableOutput{
		ID:      table.ID.String(),
		Columns: outputs,
	})
}
