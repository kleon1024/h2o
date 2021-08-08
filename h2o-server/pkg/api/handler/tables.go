package handler

import (
	"fmt"
	"h2o/api"
	"h2o/api/dao"
	"h2o/api/dto"
	"h2o/app"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

type Tables struct {
	Service *app.Server
}

func RegisterTables(r *gin.RouterGroup, svc *app.Server) {
	h := Tables{svc}
	r.POST("/:tableID/columns", h.CreateTableColumn)
	r.PUT("/:tableID/columns/:columnID", h.UpdateTableColumn)
	r.DELETE("/:tableID/columns/:columnID", h.DeleteTableColumn)
	r.POST("/:tableID/rows", h.CreateTableRow)
	r.PUT("/:tableID/rows/:rowID", h.UpdateTableRow)
	r.PATCH("/:tableID/rows/:rowID", h.PatchTableRow)
	r.DELETE("/:tableID/rows/:rowID", h.DeleteTableRow)
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
	// userValue, _ := c.Get(api.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.TableInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	body := &dto.CreateTableColumnInputBody{}
	if err := body.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if _, ok := dao.ColumnTypeMap[body.Type]; !ok {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid column type"))
		return
	}

	column := dao.Column{}
	if err := column.Exists(h.Service.Database, body.ID); err == nil {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("column already exists"))
		return
	} else if column.ID == dao.EmptyUUID {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid column id"))
		return
	}
	column.Type = body.Type
	column.Name = body.Name
	column.TableID = table.ID
	column.DefaultValue = body.DefaultValue

	if err := table.AddColumn(h.Service.Database, column); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	api.Success(c, &dto.Column{
		ID:           column.ID.String(),
		Type:         column.Type,
		Name:         column.Name,
		DefaultValue: column.DefaultValue,
	})
}

// @id UpdateTableColumn
// @summary UpdateTableColumn
// @tags Table
// @produce json
// @param tableID path string true "tableID"
// @param body body dto.UpdateTableColumnInputBody true "body"
// @success 200 {object} middleware.Response{data=dto.Column} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/tables/:tableID/columns/:columnID [PUT]
func (h *Tables) UpdateTableColumn(c *gin.Context) {
	// userValue, _ := c.Get(api.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.TableColumnInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	body := &dto.UpdateTableColumnInputBody{}
	if err := body.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if _, ok := dao.ColumnTypeMap[body.Type]; !ok {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid column type"))
		return
	}

	column := dao.Column{}
	if err := column.Exists(h.Service.Database, path.ColumnID); err != nil {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("column not exists"))
		return
	}
	if column.TableID != table.ID {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("column not in table"))
		return
	}
	column.Type = body.Type
	column.Name = body.Name
	column.DefaultValue = body.DefaultValue

	if err := table.UpdateColumn(h.Service.Database, column); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	api.Success(c, &dto.Column{
		ID:           column.ID.String(),
		Type:         column.Type,
		Name:         column.Name,
		DefaultValue: column.DefaultValue,
	})
}

// @id DeleteTableColumn
// @summary DeleteTableColumn
// @tags Table
// @produce json
// @param tableID path string true "tableID"
// @success 200 {object} middleware.Response{data=dto.Column} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/tables/:tableID/columns/:columnID [DELETE]
func (h *Tables) DeleteTableColumn(c *gin.Context) {
	// userValue, _ := c.Get(api.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC

	path := &dto.TableColumnInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	column := dao.Column{}
	if err := column.Exists(h.Service.Database, path.ColumnID); err != nil {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("column not exists"))
		return
	}
	if column.TableID != table.ID {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("column not in table"))
		return
	}

	if err := table.DropColumn(h.Service.Database, column); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	api.Success(c, &dto.Column{
		ID:           column.ID.String(),
		Type:         column.Type,
		Name:         column.Name,
		DefaultValue: column.DefaultValue,
	})
}

// @id CreateTableRow
// @summary CreateTableRow
// @tags Table
// @produce json
// @param tableID path string true "tableID"
// @param body body dto.CreateTableRowInput true "body"
// @success 200 {object} middleware.Response{data=map[string]string} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/tables/:tableID/rows [POST]
func (h *Tables) CreateTableRow(c *gin.Context) {
	// userValue, _ := c.Get(api.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC
	path := &dto.TableInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	body := &dto.TableRowInput{}
	if err := body.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if len(body.Row) == 0 {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("empty row"))
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if err := table.InsertRow(h.Service.Database, body.Row); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	api.Success(c, body.Row)
}

// @id PatchTableRow
// @summary PatchTableRow
// @tags Table
// @produce json
// @param tableID path string true "tableID"
// @param body body map[string]string true "body"
// @success 200 {object} middleware.Response{data=map[string]string} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/tables/:tableID/rows/:rowID [PATCH]
func (h *Tables) PatchTableRow(c *gin.Context) {
	// userValue, _ := c.Get(api.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC
	path := &dto.TableRowInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	body := &dto.TableRowInput{}
	if err := body.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if len(body.Row) == 0 {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("empty row"))
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if err := table.UpdateRow(h.Service.Database, path.RowID, body.Row); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	body.Row["id"] = fmt.Sprintf("%v", path.RowID)

	api.Success(c, body.Row)
}

// @id UpdateTableRow
// @summary UpdateTableRow
// @tags Table
// @produce json
// @param tableID path string true "tableID"
// @param body body map[string]string true "body"
// @success 200 {object} middleware.Response{data=map[string]string} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/tables/:tableID/rows/:rowID [PATCH]
func (h *Tables) UpdateTableRow(c *gin.Context) {
	// userValue, _ := c.Get(api.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC
	path := &dto.TableRowInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	body := &dto.TableRowInput{}
	if err := body.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if len(body.Row) == 0 {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("empty row"))
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if err := table.UpdateRow(h.Service.Database, path.RowID, body.Row); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	body.Row["id"] = fmt.Sprintf("%v", path.RowID)

	api.Success(c, body.Row)
}

// @id DeleteTableRow
// @summary DeleteTableRow
// @tags Table
// @produce json
// @param tableID path string true "tableID"
// @success 200 {object} middleware.Response{data=map[string]string} "success"
// @failure 400 {object} middleware.Response{data=interface{}} "failure"
// @router /api/v1/tables/:tableID/rows/:rowID [DELETE]
func (h *Tables) DeleteTableRow(c *gin.Context) {
	// userValue, _ := c.Get(api.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC
	path := &dto.TableRowInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if err := table.DeleteRow(h.Service.Database, path.RowID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	api.Success(c, "success")
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
	// userValue, _ := c.Get(api.UserKey)
	// user := userValue.(dao.User)
	// TODO: RBAC
	path := &dto.TableInputPath{}
	if err := path.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}

	query := &dto.ListTableRowsInput{
		Pagination: dto.Pagination{
			Offset: dto.DefaultOffset,
			Limit:  dto.DefaultLimit,
		},
	}
	if err := query.Bind(c); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if len(query.Columns) == 0 {
		api.Error(c, http.StatusBadRequest, fmt.Errorf("no column is provided"))
		return
	}

	table := dao.Table{}
	if err := table.Exists(h.Service.Database, path.TableID); err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	columns := make([]dao.Column, 0, len(query.Columns))
	for _, columnID := range query.Columns {
		column := dao.Column{}
		if err := column.Exists(h.Service.Database, columnID); err != nil {
			api.Error(c, http.StatusBadRequest, err)
			return
		} else if column.ID == dao.EmptyUUID {
			api.Error(c, http.StatusBadRequest, fmt.Errorf("invalid column id"))
			return
		}
		columns = append(columns, column)
	}

	rows, err := table.Rows(h.Service.Database, &columns, query.Offset, query.Limit)
	if err != nil {
		api.Error(c, http.StatusBadRequest, err)
		return
	}
	if len(*rows) == 0 {
		api.Success(c, &dto.ListTableRowsOutput{
			Rows: []map[string]string{},
		})
		return
	}
	logrus.WithField("rows", *rows).Debugf("ListRows")
	api.Success(c, &dto.ListTableRowsOutput{Rows: *rows})
}
