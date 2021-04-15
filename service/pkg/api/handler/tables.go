package handler

import (
	"fmt"
	"h2o/cmd/api/app/options"
	"h2o/pkg/api/dao"
	"h2o/pkg/api/dto"
	"h2o/pkg/api/middleware"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

type Tables struct {
	Service *options.ApiService
}

func RegisterTables(r *gin.RouterGroup, svc *options.ApiService) {
	h := Tables{svc}
	r.POST("/:tableID/columns", h.CreateTableColumn)
	r.POST("/:tableID/rows", h.CreateTableRow)
	r.GET("/:tableID/rows", h.ListTableRows)
}

// @id CreateTableColumn
// @summary CreateTableColumn
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

	column := dao.Column{}
	if err := column.Exists(h.Service.Database, body.ID); err == nil {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("column already exists"))
		return
	} else if column.ID == dao.EmptyUUID {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("invalid column id"))
		return
	}
	column.Type = body.Type
	column.Name = body.Name
	column.TableID = table.ID

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
// @summary CreateTableRow
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
	body := &dto.CreateTableRowInput{}
	if err := body.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	if len(body.Row) == 0 {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("empty row"))
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	if err := table.Insert(h.Service.Database, body.Row); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	middleware.Success(c, body.Row)
}

// @id ListTableRows
// @summary ListTableRows
// @tags Table
// @produce json
// @param tableID path string true "tableID"
// @success 200 {object} middleware.Response{data=map[string]string} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/tables/:tableID/rows [GET]
func (h *Tables) ListTableRows(c *gin.Context) {
	// userValue, _ := c.Get(middleware.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC
	path := &dto.TableInputPath{}
	if err := path.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}

	query := &dto.ListTableRowsInput{
		Pagination: dto.Pagination{
			Offset: dto.DefaultOffset,
			Limit:  dto.DefaultLimit,
		},
	}
	if err := query.Bind(c); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	if len(query.Columns) == 0 {
		middleware.Error(c, http.StatusBadRequest, fmt.Errorf("no column is provided"))
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	rows, err := table.Rows(h.Service.Database, &(query.Columns), query.Offset, query.Limit)
	if err != nil {
		middleware.Error(c, http.StatusBadRequest, err)
		return
	}
	if len(*rows) == 0 {
		middleware.Success(c, &dto.ListTableRowsOutput{
			Rows: [][]string{},
		})
		return
	}
	logrus.WithField("rows", *rows).Debugf("ListRows")
	middleware.Success(c, &dto.ListTableRowsOutput{
		Rows: *rows,
	})
}
