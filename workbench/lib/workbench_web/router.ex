defmodule WorkbenchWeb.Router do
  use WorkbenchWeb, :router
  # NOTE: Pass explicit the otp_app only for tests
  use Wayfinder.PhoenixRouter, otp_app: :workbench

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:put_root_layout, html: {WorkbenchWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", WorkbenchWeb do
    pipe_through(:browser)

    get("/", PageController, :home)

    get("/optional", OptionalController, :optional)
    post("/optional", OptionalController, :optional)
    post("/optional/:parameter", OptionalController, :optional)
    get("/different/path/optional", OptionalController, :optional)
    get("/different/with/alias", OptionalController, :optional, as: :optional_different)

    post("/many-optional", OptionalController, :many_optional)
    post("/many-optional/:one", OptionalController, :many_optional)
    post("/many-optional/:one/:two", OptionalController, :many_optional)
    post("/many-optional/:one/:two/:three", OptionalController, :many_optional)

    get("/nested/controller", Nested.NestedController, :nested)

    get("/two-routes-one-action-1", TwoRoutesSameActionController, :same)
    get("/two-routes-one-action-2", TwoRoutesSameActionController, :same)

    get("/disallowed/delete", DisallowedMethodNameController, :delete)

    get("/pages/he:page/*rest", GlobController, :show)

    # Other verbs testing
    head("/other-verbs/head", OtherVerbsController, :head_action)
    options("/other-verbs/options", OtherVerbsController, :options_action)

    # Multiple verbs for the same action using match macro with individual verbs
    match(:get, "/other-verbs/match", OtherVerbsController, :match_action)
    match(:post, "/other-verbs/match", OtherVerbsController, :match_action)
    match(:put, "/other-verbs/match", OtherVerbsController, :match_action)
    match(:patch, "/other-verbs/match", OtherVerbsController, :match_action)
    match(:get, "/other-verbs/match/:id", OtherVerbsController, :match_with_params)
    match(:post, "/other-verbs/match/:id", OtherVerbsController, :match_with_params)

    resources("/resources", ResourcesController)

    scope "/backoffice" do
      get("/invisible", IgnoreMeController, :ignore_me)
    end
  end
end
