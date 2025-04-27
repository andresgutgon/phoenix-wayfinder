import Config

config :workbench,
  generators: [timestamp_type: :utc_datetime]

config :workbench, WorkbenchWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: WorkbenchWeb.ErrorHTML, json: WorkbenchWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Workbench.PubSub,
  live_view: [signing_salt: "uVhNlE9C"]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :wayfinder,
  router: WorkbenchWeb.Router,
  ignore_paths: ["^/backoffice"]

import_config "#{config_env()}.exs"
