package handler

import (
	"fmt"
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/dao"
	"h2o/pkg/api/dto"
	"h2o/pkg/api/middleware"
	"h2o/pkg/config"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Blocks struct {
	Service *options.ApiService
}

func RegisterBlocks(r *gin.RouterGroup, svc *options.ApiService) {
	h := Blocks{svc}
	r.PUT("/:blockID", h.UpdateBlock)
	r.PATCH("/:blockID", h.PatchBlock)
	r.DELETE("/:blockID", h.DeleteBlock)
}

// @id UpdateBlock
// @summary 全量更新区块
// @tags Block
// @produce json
// @param blockID path string true "blockID"
// @param body body dto.UpdateBlockInput true "body"
// @success 200 {object} middleware.Response{data=dto.BlockOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/blocks/:blockID [PUT]
func (h *Blocks) UpdateBlock(c *gin.Context) {
	userValue, _ := c.Get(middleware.UserKey)
	user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.BlockInputPath{}
	if err := path.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	body := &dto.UpdateBlockInputBody{}
	if err := body.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	blockID, _ := uuid.Parse(path.BlockID)
	block := dao.Block{
		ID: blockID,
	}
	if blockExists, err := block.Exists(h.Service.Database); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	} else if !blockExists {
		middleware.Error(c, http.StatusNotFound, err)
		return
	}

	if _, ok := dao.BlockTypeMap[body.Type]; !ok {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid block type"))
		return
	}
	block.Type = body.Type

	if len(strings.TrimSpace(body.Text)) == 0 {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid block text"))
		return
	}
	block.Text = body.Text

	nodeID, _ := uuid.Parse(body.NodeID)
	node := dao.Node{
		ID: nodeID,
	}
	if nodeExists, err := node.Exists(h.Service.Database); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	} else if !nodeExists {
		middleware.Error(c, http.StatusNotFound, err)
		return
	}
	block.NodeID = nodeID

	subBlockID, _ := uuid.Parse(body.SubBlockID)
	block.SubBlockID = subBlockID

	block.UpdatedBy = user

	if err := block.Save(h.Service.Database); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	middleware.Success(c, &dto.BlockOutput{
		ID:        block.ID.String(),
		Text:      block.Text,
		Type:      block.Type,
		Revision:  block.Revision,
		AuthorID:  block.UpdatedUserID.String(),
		UpdatedAt: block.UpdatedAt.Format(config.DateFormatString),
	})
}

// @id PatchBlock
// @summary 增量更新区块
// @tags Block
// @produce json
// @param blockID path string true "blockID"
// @param body body dto.PatchBlockInput true "body"
// @success 200 {object} middleware.Response{data=dto.BlockOutput} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/blocks/:blockID [PATCH]
func (h *Blocks) PatchBlock(c *gin.Context) {
	userValue, _ := c.Get(middleware.UserKey)
	user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.BlockInputPath{}
	if err := path.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	body := &dto.PatchBlockInputBody{}
	if err := body.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	blockID, _ := uuid.Parse(path.BlockID)
	block := dao.Block{
		ID: blockID,
	}
	if blockExists, err := block.Exists(h.Service.Database); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	} else if !blockExists {
		middleware.Error(c, http.StatusNotFound, err)
		return
	}

	if body.Type != "" {
		if _, ok := dao.BlockTypeMap[body.Type]; !ok {
			middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid block type"))
			return
		}
		block.Type = body.Type
	}

	if body.Text != "" {
		if len(strings.TrimSpace(body.Text)) == 0 {
			middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid block text"))
			return
		}
		block.Text = body.Text
	}

	if body.NodeID != "" {
		nodeID, _ := uuid.Parse(body.NodeID)
		node := dao.Node{
			ID: nodeID,
		}
		if nodeExists, err := node.Exists(h.Service.Database); err != nil {
			middleware.Error(c, http.StatusBadRequest, err)
			return
		} else if !nodeExists {
			middleware.Error(c, http.StatusNotFound, err)
			return
		}
		block.NodeID = nodeID
	}

	if body.SubBlockID != "" {
		subBlockID, _ := uuid.Parse(body.SubBlockID)
		block.SubBlockID = subBlockID
	}

	block.UpdatedBy = user

	if err := block.Save(h.Service.Database); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	middleware.Success(c, &dto.BlockOutput{
		ID:        block.ID.String(),
		Text:      block.Text,
		Type:      block.Type,
		Revision:  block.Revision,
		AuthorID:  block.UpdatedUserID.String(),
		UpdatedAt: block.UpdatedAt.Format(config.DateFormatString),
	})
}

// @id DeleteBlock
// @summary 删除区块
// @tags Block
// @produce json
// @param blockID path string true "blockID"
// @success 200 {object} middleware.Response{data=interface{}} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/blocks/:blockID [DELETE]
func (h *Blocks) DeleteBlock(c *gin.Context) {
	userValue, _ := c.Get(middleware.UserKey)
	user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.BlockInputPath{}
	if err := path.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	blockID, _ := uuid.Parse(path.BlockID)
	block := dao.Block{
		ID: blockID,
	}
	if blockExists, err := block.Exists(h.Service.Database); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	} else if !blockExists {
		middleware.Error(c, http.StatusNotFound, err)
		return
	}

	block.Deleted = 1
	block.UpdatedBy = user
	block.DeletedBy = user

	if err := block.Save(h.Service.Database); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	middleware.Success(c, &dto.BlockOutput{
		ID:        block.ID.String(),
		Text:      block.Text,
		Type:      block.Type,
		Revision:  block.Revision,
		AuthorID:  block.UpdatedUserID.String(),
		UpdatedAt: block.UpdatedAt.Format(config.DateFormatString),
	})
}
