defmodule Workbench.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WorkbenchWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:workbench, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Workbench.PubSub},
      # Start a worker by calling: Workbench.Worker.start_link(arg)
      # {Workbench.Worker, arg},
      # Start to serve requests, typically the last entry
      WorkbenchWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Workbench.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WorkbenchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
