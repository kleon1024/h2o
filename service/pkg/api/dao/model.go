package dao

var Models []interface{}

func init() {
	Models = append(
		Models,
		Block{},
		BlockAttribute{},
		BlockRevision{},
		Node{},
		User{},
		Team{},
		Table{},
		Column{},
	)
}
