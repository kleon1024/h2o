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

	block := dao.Block{}
	if err := block.Exists(h.Service.Database, path.BlockID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	} else if block.ID == dao.EmptyUUID {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid block id"))
		return
	}

	preBlock := dao.Block{}
	if err := preBlock.Exists(h.Service.Database, body.PreBlockID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	block.PreBlockID = preBlock.ID

	posBlock := dao.Block{}
	if err := posBlock.Exists(h.Service.Database, body.PosBlockID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	block.PosBlockID = posBlock.ID

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

	node := dao.Node{}
	if err := node.Exists(h.Service.Database, body.NodeID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	block.NodeID = node.ID

	subBlockID, _ := uuid.Parse(body.SubBlockID)
	block.SubBlockID = subBlockID

	block.UpdatedBy = user

	if err := block.Save(h.Service.Database, &preBlock, &posBlock); err != nil {
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

	block := dao.Block{}
	if err := block.Exists(h.Service.Database, path.BlockID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	} else if block.ID == dao.EmptyUUID {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid block id"))
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
		node := dao.Node{}
		if err := node.Exists(h.Service.Database, body.NodeID); err != nil {
			middleware.Error(c, http.StatusBadRequest, err)
			return
		} else if node.ID == dao.EmptyUUID {
			middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid node id"))
			return
		}
		block.NodeID = node.ID
	}

	if body.SubBlockID != "" {
		subBlockID, err := uuid.Parse(body.SubBlockID)
		if err != nil {
			middleware.Error(c, http.StatusBadRequest, err)
			return
		}
		block.SubBlockID = subBlockID
	}

	preBlock := dao.Block{}
	if body.PreBlockID != "" {
		if err := preBlock.Exists(h.Service.Database, body.PreBlockID); err != nil {
			middleware.Error(c, http.StatusBadRequest, err)
			return
		}
		block.PreBlockID = preBlock.ID
	}

	posBlock := dao.Block{}
	if body.PosBlockID != "" {
		if err := posBlock.Exists(h.Service.Database, body.PosBlockID); err != nil {
			middleware.Error(c, http.StatusBadRequest, err)
			return
		}
		block.PosBlockID = posBlock.ID
	}

	block.UpdatedBy = user
	if err := block.Save(h.Service.Database, &preBlock, &posBlock); err != nil {
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

	block := dao.Block{}
	if err := block.Exists(h.Service.Database, path.BlockID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	preBlock, err := block.FindPreBlock(h.Service.Database)
	if err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	posBlock, err := block.FindPosBlock(h.Service.Database)
	if err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	if posBlock.ID != dao.EmptyUUID {
		if preBlock.ID != dao.EmptyUUID {
			preBlock.PosBlockID = posBlock.ID
			posBlock.PreBlockID = preBlock.ID
		} else {
			posBlock.PreBlockID = dao.EmptyUUID
		}
	} else if preBlock.ID != dao.EmptyUUID {
		preBlock.PosBlockID = dao.EmptyUUID
	}

	block.Deleted = 1
	block.UpdatedBy = user
	block.DeletedBy = user

	if err := block.Save(h.Service.Database, preBlock, posBlock); err != nil {
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
