package middleware

import (
	"reflect"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/locales/en"
	"github.com/go-playground/locales/zh"
	ut "github.com/go-playground/universal-translator"
	"github.com/go-playground/validator/v10"
	en_translations "github.com/go-playground/validator/v10/translations/en"
	zh_translations "github.com/go-playground/validator/v10/translations/zh"
)

func Translation() gin.HandlerFunc {
	return func(c *gin.Context) {
		en := en.New()
		zh := zh.New()

		uni := ut.New(zh, en)
		val := validator.New()

		locale := c.DefaultQuery("locale", "zh")
		trans, _ := uni.GetTranslator(locale)

		switch locale {
		case "en":
			en_translations.RegisterDefaultTranslations(val, trans)
			val.RegisterTagNameFunc(func(fld reflect.StructField) string {
				return fld.Tag.Get("en_comment")
			})
			break
		case "zh":
			zh_translations.RegisterDefaultTranslations(val, trans)
			val.RegisterTagNameFunc(func(fld reflect.StructField) string {
				return fld.Tag.Get("comment")
			})
			break
		}
		c.Set(TranslatorKey, trans)
		c.Set(ValidatorKey, val)
		c.Next()
	}
}
