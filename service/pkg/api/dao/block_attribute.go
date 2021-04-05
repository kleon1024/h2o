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
	ID        uint      `gorm:"primary_key;auto_increment"`
	BlockUUID uuid.UUID `gorm:"column:block_uuid;type:char(36)"`
	Block     Block     `gorm:"foreignkey:BlockUUID"`
	Key       string    `gorm:"column:key"`
	Value     string    `gorm:"column:value"`
}
