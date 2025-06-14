require Logger
defmodule Wayfinder do
  @moduledoc false

  alias Wayfinder.{Generator, Options, Processor}

  @spec generate(module(), atom()) :: :ok | {:error, Wayfinder.Error.t()}
  def generate(router, otp_app) do
    case Options.build_opts(router, otp_app) do
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
