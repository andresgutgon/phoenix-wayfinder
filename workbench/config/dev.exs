import Config

config :workbench, WorkbenchWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "tpa2vX9gF1/rmLoEdLf/fNR4w0BRE8r+rwZHtLub6otEp8oj13qIw984silfPmS7",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:workbench, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:workbench, ~w(--watch)]}
  ]

config :workbench, dev_routes: true
config :logger, :default_formatter, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
