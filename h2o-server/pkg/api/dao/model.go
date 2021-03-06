package dao

import "github.com/google/uuid"

var EmptyUUID uuid.UUID = uuid.UUID{}

var Models []interface{}

func init() {
	Models = append(
		Models,
		Block{},
		BlockRevision{},
		Node{},
		User{},
		Team{},
		Table{},
		TableReferenceBlock{},
		Column{},
		NumberedListBlock{},
		ImageBlock{},
		CheckboxBlock{},
		TeamMember{},
	)
}
