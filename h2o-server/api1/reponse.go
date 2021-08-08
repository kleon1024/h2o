package api1

import (
	"encoding/json"

	"github.com/gin-gonic/gin"
)

type ResponseCode int32

const (
	SuccessCode ResponseCode = iota
)

type Response struct {
	ErrorCode    ResponseCode `json:"errorCode"`
	ErrorMessage string       `json:"errorMessage"`
	Data         interface{}  `json:"data"`
}

func Error(c *gin.Context, code ResponseCode, err error) {
	resp := &Response{ErrorCode: code, ErrorMessage: err.Error(), Data: struct{}{}}
	httpStatusCode := 500
	if code < 1000 {
		httpStatusCode = int(code)
	}
	c.JSON(httpStatusCode, resp)
	response, _ := json.Marshal(resp)
	c.Set("response", string(response))
	c.AbortWithError(httpStatusCode, err)
}

func Success(c *gin.Context, data interface{}) {
	resp := &Response{ErrorCode: SuccessCode, ErrorMessage: "", Data: data}
	c.JSON(200, resp)
	response, _ := json.Marshal(resp)
	c.Set("response", string(response))
}
