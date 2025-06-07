defmodule Wayfinder do
  @moduledoc false

  alias Wayfinder.{Generator, Options, Processor}

  @spec generate(module(), atom() | nil) :: :ok | {:error, Wayfinder.Error.t()}
  def generate(router, test_otp_app \\ nil) do
    case Options.build_opts(router, test_otp_app) do
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
