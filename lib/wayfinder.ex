require Logger

defmodule Wayfinder do
  @moduledoc false
  alias Wayfinder.{Options, Processor}

  @spec generate(module(), Options.t()) :: :ok | {:error, Wayfinder.Error.t()}
  def generate(router, _opts) do
    case Processor.call(router) do
      {:ok, _collections} ->
        :ok
      {:error, error} ->
        Logger.error("Wayfinder failed: #{error.message} (#{inspect(error.reason)})")
        {:error, error}
    end
  end
end
