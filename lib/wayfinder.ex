require Logger

defmodule Wayfinder do
  @moduledoc false

  alias Wayfinder.{Generator, Error, Options, Processor}

  @spec generate(module(), [String.t()] | nil) :: :ok | {:error, Wayfinder.Error.t()}
  def generate(router, cli_args) do
    case Options.build_opts(router, cli_args) do
      {:ok, %Options{} = opts} ->
        case Processor.call(router) do
          {:ok, routes} ->
            Generator.call(routes, opts)

          {:error, error} ->
            log_error(error)
        end

      {:error, error} ->
        log_error(error)
    end
  end

  @spec log_error(Error.t()) :: {:error, Exception.t()}
  def log_error(error) do
    Logger.error("Wayfinder failed: #{error.message} (#{inspect(error.reason)})")
    {:error, error}
  end
end
