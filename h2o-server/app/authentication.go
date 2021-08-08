package app

import (
	"h2o/model"
	"strings"

	"github.com/gin-gonic/gin"
)

type TokenLocation int

const (
	TokenLocationNotFound TokenLocation = iota
	TokenLocationHeader
	TokenLocationCookie
	TokenLocationQueryString
	TokenLocationCloudHeader
	TokenLocationRemoteClusterHeader
)

func (tl TokenLocation) String() string {
	switch tl {
	case TokenLocationNotFound:
		return "Not Found"
	case TokenLocationHeader:
		return "Header"
	case TokenLocationCookie:
		return "Cookie"
	case TokenLocationQueryString:
		return "QueryString"
	case TokenLocationCloudHeader:
		return "CloudHeader"
	case TokenLocationRemoteClusterHeader:
		return "RemoteClusterHeader"
	default:
		return "Unknown"
	}
}

func ParseAuthTokenFromRequest(ctx *gin.Context) (string, TokenLocation) {
	// Get cookie first
	if cookie, err := ctx.Cookie(model.SessionCookieToken); err == nil {
		return cookie, TokenLocationCookie
	}

	authHeader := ctx.Request.Header.Get(model.HEADER_AUTH)
	if len(authHeader) > 6 && strings.ToUpper(authHeader[0:6]) == model.HEADER_BEARER {
		// Default session token
		return authHeader[7:], TokenLocationHeader
	}

	if len(authHeader) > 5 && strings.ToLower(authHeader[0:5]) == model.HEADER_BEARER {
		// OAuth token
		return authHeader[6:], TokenLocationHeader
	}

	if token := ctx.Request.URL.Query().Get("access_token"); token != "" {
		return token, TokenLocationQueryString
	}

	// if token := ctx.Request.Header.Get(model.HEADER_CLOUD_TOKEN); token != "" {
	// 	return token, TokenLocationCloudHeader
	// }

	// if token := ctx.Request.Header.Get(model.HEADER_REMOTECLUSTER_TOKEN); token != "" {
	// 	return token, TokenLocationRemoteClusterHeader
	// }

	return "", TokenLocationNotFound
}
