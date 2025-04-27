defmodule WorkbenchWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :workbench

  @session_options [
    store: :cookie,
    key: "_workbench_key",
    signing_salt: "b8crY3L8",
    same_site: "Lax"
  ]

  plug(Plug.Static,
    at: "/",
    from: :workbench,
    gzip: not code_reloading?,
    only: WorkbenchWeb.static_paths()
  )

  plug(Plug.RequestId)
  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(WorkbenchWeb.Router)
end
