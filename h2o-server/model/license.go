package model

type License struct {
	Id           string `json:"id"`
	IssuedAt     int64  `json:"issued_at"`
	StartsAt     int64  `json:"starts_at"`
	ExpiresAt    int64  `json:"expires_at"`
	SkuName      string `json:"sku_name"`
	SkuShortName string `json:"sku_short_name"`
	IsTrial      bool   `json:"is_trial"`
}
