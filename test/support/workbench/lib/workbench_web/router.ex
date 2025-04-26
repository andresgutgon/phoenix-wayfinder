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

    get("/", PageController, :home)
    get("/invokable-controller", InvokableController, :show)
    get("/invokable-plus-controller", InvokablePlusController, :index)
    post("/invokable-plus-controller", InvokablePlusController, :store)

    get("/posts", PostController, :index, as: :posts_index)
    get("/posts/create", PostController, :create, as: :posts_create)
    post("/posts", PostController, :store, as: :posts_store)
    get("/posts/:post_id", PostController, :show, as: :posts_show)
    get("/posts/:post_id/edit", PostController, :edit, as: :posts_edit)
    patch("/posts/:post_id", PostController, :update, as: :posts_update)
    delete("/posts/:post_id", PostController, :destroy, as: :posts_destroy)

    get("/dashboard", PageController, :dashboard)

    post("/optional/:parameter", OptionalController, :optional)
    post("/many-optional/:one/:two/:three", OptionalController, :many_optional)

    post("/users/:user_id", ModelBindingController, :show)

    get("/keys/:key", KeyController, :show)
    get("/keys/:key/uuid/edit", KeyController, :edit)

    get("/parameter-names/:camel_case/camel", ParameterNameController, :camel)
    get("/parameter-names/:studly_case/studly", ParameterNameController, :studly)
    get("/parameter-names/:snake_case/snake", ParameterNameController, :snake)

    get(
      "/parameter-names/:screaming_snake_case/screaming-snake",
      ParameterNameController,
      :screaming_snake
    )

    get("/nested/controller", Nested.NestedController, :nested)

    get("/two-routes-one-action-1", TwoRoutesSameActionController, :same)
    get("/two-routes-one-action-2", TwoRoutesSameActionController, :same)

    get("/disallowed/delete", DisallowedMethodNameController, :delete)
    get("/disallowed/404", DisallowedMethodNameController, :error_404, as: :disallowed_404)

    get("/anonymous-middleware", AnonymousMiddlewareController, :show)
  end

  scope "/api/v1", WorkbenchWeb.Api.V1, as: :api_v1 do
    pipe_through(:api)

    get("/tasks", TaskController, :tasks)

    scope "/tasks/:task_id/task-status", as: :task_status do
      get("/", TaskStatusController, :index)
    end
  end
end
