require Logger

defmodule Wayfinder do
  @moduledoc false
  alias Wayfinder.{Options, Processor}

  @spec generate(module(), Options.t()) :: :ok | {:error, Wayfinder.Error.t()}

  def generate(router, _opts) do
    case Processor.call(router) do
      :ok ->
        :ok
      {:error, %Wayfinder.Error{message: msg, reason: reason}} ->
        Logger.error("Wayfinder failed: #{msg} (#{inspect(reason)})")
        {:error, reason}
    end
  end
end
