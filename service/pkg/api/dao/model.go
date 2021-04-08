package dao

var Models []interface{}

func init() {
	Models = append(
		Models,
		Block{},
		BlockRevision{},
		Node{},
		User{},
		Team{},
		TableBlock{},
		TableReferenceBlock{},
		Column{},
		NumberedListBlock{},
		ImageBlock{},
		CheckboxBlock{},
	)
}
