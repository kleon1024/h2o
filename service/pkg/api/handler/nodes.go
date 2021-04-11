package handler

import (
	"fmt"
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/dao"
	"h2o/pkg/api/dto"
	"h2o/pkg/api/middleware"
	"h2o/pkg/config"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Nodes struct {
	Service *options.ApiService
}

func RegisterNodes(r *gin.RouterGroup, svc *options.ApiService) {
	h := Nodes{svc}
	r.GET("/:nodeID/blocks", h.ListNodeBlocks)
	r.POST("/:nodeID/blocks", h.CreateNodeBlock)
}

// @id ListNodeBlocks
// @summary 获取节点区块
// @tags Node
// @produce json
// @param nodeID path string true "nodeID"
// @param body body dto.Pagination true "body"
// @success 200 {object} middleware.Response{data=dto.BlockOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/nodes/:nodeID/blocks [GET]
func (h *Nodes) ListNodeBlocks(c *gin.Context) {
	// userValue, _ := c.Get(middleware.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.ListNodeBlocksInputPath{}
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

	nodeID, _ := uuid.Parse(path.NodeID)
	node := dao.Node{
		ID: nodeID,
	}
	blocks, err := node.FindBlocks(h.Service.Database, query.Offset, query.Limit)
	if err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	outputs := make([]dto.BlockOutput, len(*blocks))
	for i, block := range *blocks {
		outputs[i].ID = block.ID.String()
		outputs[i].PreBlockID = block.PreBlockID.String()
		outputs[i].Text = block.Text
		outputs[i].Type = block.Type
		outputs[i].Revision = block.Revision
		outputs[i].AuthorID = block.UpdatedUserID.String()
		outputs[i].UpdatedAt = block.UpdatedAt.Format(config.DateFormatString)
	}

	middleware.Success(c, dto.ListNodeBlocksOutput{
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
	userValue, _ := c.Get(middleware.UserKey)
	user := userValue.(dao.User)
	// TODO: RABC

	path := &dto.ListNodeBlocksInputPath{}
	if err := path.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	body := &dto.CreateNodeBlockInputBody{}
	if err := body.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	node := dao.Node{}
	if err := node.Exists(h.Service.Database, path.NodeID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	preBlock := dao.Block{}
	if err := preBlock.Exists(h.Service.Database, body.PreBlockID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	posBlock := dao.Block{}
	if err := posBlock.Exists(h.Service.Database, body.PosBlockID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	if _, ok := dao.BlockTypeMap[body.Type]; !ok {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid block type"))
		return
	}

	block := dao.Block{
		Text:       body.Text,
		PreBlockID: preBlock.ID,
		PosBlockID: posBlock.ID,
		NodeID:     node.ID,
		Type:       body.Type,
		Revision:   0,
		CreatedBy:  user,
		UpdatedBy:  user,
	}

	if err := block.Save(h.Service.Database, &preBlock, &posBlock); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
	}

	middleware.Success(c, &dto.BlockOutput{
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
