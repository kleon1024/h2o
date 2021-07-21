package app

type App struct {
	srv *Server
}

func New(options ...AppOption) *App {
	app := &App{}

	for _, option := range options {
		option(app)
	}

	return app
}

func (a *App) Srv() *Server {
	return a.srv
}
