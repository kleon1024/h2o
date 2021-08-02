package dto

import (
	"h2o/pkg/api"

	"github.com/gin-gonic/gin"
)

type CreateTableColumnInputBody struct {
	ID           string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Type         string `json:"type" example:"type" validate:"required"`
	Name         string `json:"name" example:"name" validate:"required"`
	DefaultValue string `json:"defaultValue" example:"defaultValue"`
}

func (p *CreateTableColumnInputBody) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypeBody)
}

type TableColumnInputPath struct {
	TableInputPath
	ColumnInputPath
}

func (p *TableColumnInputPath) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypePath)
}

type TableRowInputPath struct {
	TableInputPath
	RowInputPath
}

func (p *TableRowInputPath) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypePath)
}

type UpdateTableColumnInputBody struct {
	Type         string `json:"type" example:"type" validate:"required"`
	Name         string `json:"name" example:"name" validate:"required"`
	DefaultValue string `json:"defaultValue" example:"defaultValue"`
}

func (p *UpdateTableColumnInputBody) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypeBody)
}

type ColumnInputPath struct {
	ColumnID string `json:"columnID" uri:"columnID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *ColumnInputPath) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypePath)
}

type RowInputPath struct {
	RowID int `json:"rowID" uri:"rowID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required"`
}

func (p *RowInputPath) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypePath)
}

type TableInputPath struct {
	TableID string `json:"tableID" uri:"tableID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *TableInputPath) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypePath)
}

type UpdateTableInputBody struct {
	Type       string `json:"type" example:"text" validate:"required"`
	Name       string `json:"name" example:"name" validate:"required"`
	Indent     int    `json:"indent" example:"0" validate:"required,min=0"`
	TeamID     string `json:"teamID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
	PreTableID string `json:"preTableID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
	PosTableID string `json:"posTableID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *UpdateTableInputBody) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypeBody)
}

type PatchTableInputBody struct {
	Type       string `json:"type" example:"text"`
	Name       string `json:"name" example:"name"`
	Indent     int    `json:"indent" example:"0"`
	TeamID     string `json:"teamID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	PreTableID string `json:"preTableID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	PosTableID string `json:"posTableID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
}

func (p *PatchTableInputBody) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypeBody)
}

type GetTableTableOutput struct {
	ID      string   `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Columns []Column `json:"columns"`
}

type TableRowInput struct {
	Row map[string]string `json:"row"`
}

func (p *TableRowInput) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypeBody)
}

type ListTableRowsInput struct {
	Pagination
	Columns []string `json:"columns" form:"columns"`
}

func (p *ListTableRowsInput) Bind(c *gin.Context) error {
	return api.GetValidParams(c, p, api.BindTypeQuery)
}

type ListTableRowsOutput struct {
	Rows []map[string]string `json:"rows"`
}
