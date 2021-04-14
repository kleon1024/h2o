package handler

import (
	"encoding/json"
	"fmt"
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/dao"
	"h2o/pkg/api/dto"
	"h2o/pkg/api/middleware"
	"io/ioutil"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Tables struct {
	Service *options.ApiService
}

func RegisterTables(r *gin.RouterGroup, svc *options.ApiService) {
	h := Tables{svc}
	r.POST("/:tableID/columns", h.CreateTableColumn)
	r.POST("/:tableID/rows", h.CreateTableRow)
}

// @id CreateTableColumn
// @summary 创建
// @tags Table
// @produce json
// @param tableID path string true "tableID"
// @param body body dto.CreateTableColumnInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.Column} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/tables/:tableID/columns [POST]
func (h *Tables) CreateTableColumn(c *gin.Context) {
	// userValue, _ := c.Get(middleware.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.TableInputPath{}
	if err := path.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	body := &dto.CreateTableColumnInputBody{}
	if err := body.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	if _, ok := dao.ColumnTypeMap[body.Type]; !ok {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid column type"))
		return
	}

	column := dao.Column{
		Name: body.Name,
		Type: body.Type,
	}
	if err := table.AddColumn(h.Service.Database, column); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	middleware.Success(c, &dto.Column{
		ID:   column.ID.String(),
		Type: column.Type,
		Name: column.Name,
	})
}

// @id CreateTableRow
// @summary 创建
// @tags Table
// @produce json
// @param tableID path string true "tableID"
// @param body body map[string]string true "body"
// @success 200 {object} middleware.Response{data=map[string]string} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/tables/:tableID/rows [POST]
func (h *Tables) CreateTableRow(c *gin.Context) {
	// userValue, _ := c.Get(middleware.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.TableInputPath{}
	if err := path.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	jsonData, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	rowMap := map[string]string{}
	if err := json.Unmarshal(jsonData, &rowMap); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	for id, _ := range rowMap {
		column := dao.Column{}
		if err := column.Exists(h.Service.Database, id); err != nil {
			middleware.Error(c, http.StatusBadRequest, err)
			return
		} else if column.ID == dao.EmptyUUID {
			middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid column id"))
			return
		}
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	if err := table.Insert(h.Service.Database, rowMap); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	middleware.Success(c, rowMap)
}
