require Logger

defmodule Wayfinder do
  @moduledoc false
  @dialyzer {:nowarn_function, generate: 2}

  alias Wayfinder.{Generator, Options, Processor}

  @spec generate(module(), Options.t()) :: :ok | {:error, Wayfinder.Error.t()}
  def generate(router, opts) do
    case Processor.call(router) do
      {:ok, collections} ->
        Generator.call(collections, opts)

      {:error, error} ->
        Logger.error("Wayfinder failed: #{error.message} (#{inspect(error.reason)})")
        {:error, error}
    end
  end
end
