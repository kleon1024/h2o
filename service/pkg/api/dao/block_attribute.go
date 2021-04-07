package dao

import "github.com/google/uuid"

const (
	BlockAttributeLayoutColumnRatio = "layoutColumnRatio"
	BlockAttributeLayoutIndentLevel = "layoutIndentLevel"

	BlockAttributeText              = "text"
	BlockAttributeCheckboxChecked   = "checkboxChecked"
	BlockAttributeToogleListToggled = "toggleListToggled"

	BlockAttributeFileUrl      = "fileUrl"
	BlockAttributeFileExternal = "fileExternal"

	BlockAttributeDatabase           = "database"
	BlockAttributeDatabaseRows       = "databaseRows"
	BlockAttributeDatabaseColumns    = "databaseColumns"
	BlockAttributeDatabaseVisualMode = "databaseVisualMode"

	BlockAttributeReferenceBlock    = "referenceBlock"
	BlockAttributeReferenceNode     = "referenceNode"
	BlockAttributeReferenceReadOnly = "referenceReadOnly"

	BlockAttributeChartX     = "chartX"
	BlockAttributeChartY     = "chartY"
	BlockAttributeChartHue   = "chartHue"
	BlockAttributeChartStyle = "chartStyle"
)

type BlockAttribute struct {
	ID      uuid.UUID `gorm:"type:char(36);primary_key"`
	BlockID uuid.UUID `gorm:"type:char(36)"`
	Block   Block     `gorm:"foreignkey:BlockID"`
	Key     string    `gorm:"column:key"`
	Value   string    `gorm:"column:value"`
}
