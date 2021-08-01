package api

import (
	"fmt"
	"h2o/pkg/api/dao"
	"h2o/pkg/app"
	"h2o/pkg/config"
	"h2o/pkg/util/orm"
	"net/http"
	"strings"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

const (
	JWTSubjectAccessToken  = "AccessToken"
	JWTSubjectRefreshToken = "RefreshToken"
)

func generateToken(subject string, expiresTime time.Time, user *dao.User, config *config.JWTConfig) (string, error) {
	claims := jwt.StandardClaims{
		Audience:  user.Name,
		ExpiresAt: expiresTime.Unix(),
		Id:        user.ID.String(),
		IssuedAt:  time.Now().Unix(),
		Issuer:    config.Issuer,
		NotBefore: time.Now().Unix(),
		Subject:   subject,
	}
	logrus.WithField("subject", subject).WithField("audience", user.Name).WithField("id", user.ID).Debug("generateToken")
	jwtSecret := []byte(config.Secret)
	return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(jwtSecret)
}

func GenerateTokens(user *dao.User, config *config.JWTConfig) (accessToken string, accessTokenExpiresAt time.Time, refreshToken string, refreshTokenExpiresAt time.Time, err error) {
	accessTokenExpiresAt = time.Now().UTC().Add(time.Hour * time.Duration(config.AccessTokenExpireHours))
	accessToken, err = generateToken(
		JWTSubjectAccessToken,
		accessTokenExpiresAt,
		user,
		config,
	)
	if err != nil {
		return
	}
	refreshTokenExpiresAt = time.Now().UTC().Add(time.Hour * time.Duration(config.RefreshTokenExpireDays*24))
	refreshToken, err = generateToken(
		JWTSubjectRefreshToken,
		refreshTokenExpiresAt,
		user,
		config,
	)
	return
}

func JWT(svc *app.Server, subject string, required bool) gin.HandlerFunc {
	return func(c *gin.Context) {
		jwtConfig := svc.ServiceConfig.JWTConfig
		authorization := c.Request.Header.Get("Authorization")
		if authorization == "" {
			if required {
				Error(c, http.StatusUnauthorized, fmt.Errorf("required authorization"))
			}
			return
		}
		tokens := strings.Split(authorization, " ")
		if len(tokens) < 2 || tokens[0] != "Bearer" {
			Error(c, http.StatusBadRequest, fmt.Errorf("invalid token format"))
			return
		}
		tokenString := tokens[1]
		token, err := jwt.ParseWithClaims(tokenString, &jwt.StandardClaims{}, func(token *jwt.Token) (interface{}, error) {
			return []byte(jwtConfig.Secret), nil
		})
		logrus.WithField("error", err).Debug()
		claims, ok := token.Claims.(*jwt.StandardClaims)
		if ok && token.Valid && claims.Issuer == jwtConfig.Issuer && claims.Subject == subject {
			userId, err := uuid.Parse(claims.Id)
			logrus.WithField("userId", userId).Debug()
			if err != nil {
				Error(c, http.StatusBadRequest, fmt.Errorf("invalid user id"))
				return
			}

			user := dao.User{
				ID:   userId,
				Name: claims.Audience,
			}
			users, err := user.Find(svc.Database, 0, 1, []orm.WhereCondition{})
			if err != nil {
				Error(c, http.StatusBadRequest, err)
				return
			}
			if len(*users) == 0 {
				Error(c, http.StatusBadRequest, fmt.Errorf("invalid user"))
				return
			}
			c.Set(UserKey, (*users)[0])
			c.Set(TokenSubjectKey, claims.Subject)
		} else {
			Error(c, http.StatusBadRequest, fmt.Errorf("invalid token"))
			return
		}
	}
}
