import Config

config :workbench, WorkbenchWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "5Ej/tfakxHvUKVr4tXGSd9YumPyO9N1OetE/fQ/eZ6jT1c6Fdh0+pOhjTXdGQctj",
  server: false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
