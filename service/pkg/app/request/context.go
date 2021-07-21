package request

import (
	"context"
	"h2o/pkg/model"
)

type Context struct {
	session        model.Session
	requestId      string
	ipAddress      string
	path           string
	userAgent      string
	acceptLanguage string

	context context.Context
}

func NewContext(ctx context.Context, requestId, ipAddress, path, userAgent, acceptLanguage string, session model.Session) *Context {
	return &Context{
		session:        session,
		requestId:      requestId,
		ipAddress:      ipAddress,
		path:           path,
		userAgent:      userAgent,
		acceptLanguage: acceptLanguage,
		context:        ctx,
	}
}

func EmptyContext() *Context {
	return &Context{
		context: context.Background(),
	}
}

func (c *Context) Session() *model.Session {
	return &c.session
}
func (c *Context) RequestId() string {
	return c.requestId
}
func (c *Context) IpAddress() string {
	return c.ipAddress
}
func (c *Context) Path() string {
	return c.path
}
func (c *Context) UserAgent() string {
	return c.userAgent
}
func (c *Context) AcceptLanguage() string {
	return c.acceptLanguage
}

func (c *Context) Context() context.Context {
	return c.context
}

func (c *Context) SetSession(s *model.Session) {
	c.session = *s
}

func (c *Context) SetRequestId(s string) {
	c.requestId = s
}
func (c *Context) SetIpAddress(s string) {
	c.ipAddress = s
}
func (c *Context) SetUserAgent(s string) {
	c.userAgent = s
}
func (c *Context) SetAcceptLanguage(s string) {
	c.acceptLanguage = s
}
func (c *Context) SetPath(s string) {
	c.path = s
}
func (c *Context) SetContext(ctx context.Context) {
	c.context = ctx
}
