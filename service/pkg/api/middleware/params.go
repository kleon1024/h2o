package middleware

import (
	"errors"
	"fmt"
	"strings"

	"github.com/gin-gonic/gin"
	ut "github.com/go-playground/universal-translator"
	"github.com/go-playground/validator/v10"
)

const (
	ValidatorKey    = "Validator"
	TranslatorKey   = "Translator"
	UserKey         = "User"
	TokenSubjectKey = "TokenSubject"
)

const (
	BindTypePath = iota
	BindTypeQuery
	BindTypeBody
	BindTypeHeader
)

func GetValidParams(c *gin.Context, params interface{}, bind int) error {
	bindFunc := c.ShouldBind
	switch bind {
	case BindTypePath:
		bindFunc = c.ShouldBindUri
	case BindTypeHeader:
		bindFunc = c.ShouldBindHeader
	}
	if err := bindFunc(params); err != nil {
		return err
	}
	valid, err := getValidator(c)
	if err != nil {
		return err
	}
	trans, err := getTranslator(c)
	if err != nil {
		return err
	}
	err = valid.Struct(params)
	if err != nil {
		errs := err.(validator.ValidationErrors)
		sliceErrs := []string{}
		for _, e := range errs {
			sliceErrs = append(sliceErrs, e.Translate(trans))
		}
		return errors.New(strings.Join(sliceErrs, ","))
	}
	return nil
}

func getValidator(c *gin.Context) (*validator.Validate, error) {
	val, ok := c.Get(ValidatorKey)
	if !ok {
		return nil, fmt.Errorf("cannot find any validator")
	}
	validator, ok := val.(*validator.Validate)
	if !ok {
		return nil, fmt.Errorf("failed to get validator")
	}
	return validator, nil
}

func getTranslator(c *gin.Context) (ut.Translator, error) {
	trans, ok := c.Get(TranslatorKey)
	if !ok {
		return nil, fmt.Errorf("cannot find any translator")
	}
	translator, ok := trans.(ut.Translator)
	if !ok {
		return nil, fmt.Errorf("failed to get translator")
	}
	return translator, nil
}
