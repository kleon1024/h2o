package dto

type ListTeamsOutput struct {
	Pagination
	PaginationStream
	Teams []ListTeamsInstance `json:"teams"`
}

type ListTeamsInstance struct {
	ID   string `json:"id" example:"0f1400e6-bec9-458d-94c6-cfca966710d4"`
	Name string `json:"name" example:"UserName" validate:"max=18,min=3"`
}
