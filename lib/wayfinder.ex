defmodule Wayfinder do
  @moduledoc false

  alias Wayfinder.{Generator, Options, Processor}

  @spec generate(module(), [String.t()] | nil) ::
          :ok | {:error, Wayfinder.Error.t()}
  def generate(router, cli_args) do
    case Options.build_opts(router, cli_args) do
      {:ok, %Options{} = opts} ->
        case Processor.call(router) do
          {:ok, controllers} ->
            Generator.call(controllers, opts)

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end
end
