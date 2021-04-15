package dto

import (
	"h2o/pkg/api/middleware"

	"github.com/gin-gonic/gin"
)

type ListTableColumnsInputPath struct {
	TableID string `json:"tableID" uri:"tableID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *ListTableColumnsInputPath) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypePath)
}

type CreateTableColumnInputBody struct {
	ID      string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Type    string `json:"type" example:"type" validate:"required"`
	Name    string `json:"name" example:"name" validate:"required"`
	Default string `json:"default" example:"default"`
}

func (p *CreateTableColumnInputBody) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}

type TableInputPath struct {
	TableID string `json:"tableID" uri:"tableID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
}

func (p *TableInputPath) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypePath)
}

type TableOutput struct {
	ID         string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Type       string `json:"type" example:"directory"`
	Name       string `json:"name" example:"This is an example"`
	Indent     int    `json:"indent" example:"0" validate:"required"`
	TeamID     string `json:"teamID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4" validate:"required,uuid"`
	PreTableID string `json:"preTableID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	PosTableID string `json:"posTableID" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
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
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
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
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}

type GetTableTableOutput struct {
	ID      string   `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Columns []Column `json:"columns"`
}

type CreateTableRowInput struct {
	Row map[string]string `json:"row"`
}

func (p *CreateTableRowInput) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeBody)
}

type ListTableRowsInput struct {
	Pagination
	Columns []string `json:"columns" form:"columns"`
}

func (p *ListTableRowsInput) Bind(c *gin.Context) error {
	return middleware.GetValidParams(c, p, middleware.BindTypeQuery)
}

type ListTableRowsOutput struct {
	Rows []map[string]string `json:"rows"`
}
