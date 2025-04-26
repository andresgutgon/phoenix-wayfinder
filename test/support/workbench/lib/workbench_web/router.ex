defmodule WorkbenchWeb.Router do
  use WorkbenchWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, html: {WorkbenchWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", WorkbenchWeb do
    pipe_through :browser

    get "/", PageController, :home
  end
end
