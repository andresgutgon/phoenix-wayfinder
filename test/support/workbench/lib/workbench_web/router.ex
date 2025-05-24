defmodule WorkbenchWeb.Router do
  use WorkbenchWeb, :router

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

    # get("/", PageController, :home)
    # get("/posts", PostController, :index, as: :posts_index)
    # get("/posts/create", PostController, :create, as: :posts_create)
    # post("/posts", PostController, :store, as: :posts_store)
    # get("/posts/:post_id", PostController, :show, as: :posts_show)
    # get("/posts/:post_id/edit", PostController, :edit, as: :posts_edit)
    # patch("/posts/:post_id", PostController, :update, as: :posts_update)
    # delete("/posts/:post_id", PostController, :destroy, as: :posts_destroy)

    # get("/dashboard", PageController, :dashboard)

    # Combinations
    # get("/optional", OptionalController, :optional)
    # post("/optional", OptionalController, :optional)
    # post("/optional/:parameter", OptionalController, :optional)
    # get("/different/path/optional", OptionalController, :optional)
    # get("/different/with/alias", OptionalController, :optional, as: :optional_different)

    # post("/many-optional", OptionalController, :many_optional)
    # post("/many-optional/:one", OptionalController, :many_optional)
    # post("/many-optional/:one/:two", OptionalController, :many_optional)
    # post("/many-optional/:one/:two/:three", OptionalController, :many_optional)

    # post("/users/:user_id", ModelBindingController, :show)

    # get("/keys/:key", KeyController, :show)
    # get("/keys/:key/edit", KeyController, :edit)

    # get("/parameter-names/:camel_case/camel", ParameterNameController, :camel)
    # get("/parameter-names/:studly_case/studly", ParameterNameController, :studly)
    # get("/parameter-names/:snake_case/snake", ParameterNameController, :snake)

    # get(
    #   "/parameter-names/:screaming_snake_case/screaming-snake",
    #   ParameterNameController,
    #   :screaming_snake
    # )

    # get("/nested/controller", Nested.NestedController, :nested)

    # get("/two-routes-one-action-1", TwoRoutesSameActionController, :same)
    # get("/two-routes-one-action-2", TwoRoutesSameActionController, :same)

    get("/disallowed/delete", DisallowedMethodNameController, :delete)

    # get("/anonymous-middleware", AnonymousMiddlewareController, :show)
  end
end
