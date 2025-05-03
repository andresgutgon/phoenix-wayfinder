require Logger

defmodule Wayfinder.Processor do
  @moduledoc false

  alias Wayfinder.{Routes, Error}
  alias Wayfinder.Processor.Route

  @spec call(module()) :: {:ok, Collections.t()} | {:error, Error.t()}
  def call(router) do
    try do
      {:ok, %Routes{actions: collect(router)}}
    rescue
      error ->
        {:error, Error.new(Exception.message(error), :processor_failure)}
    end
  end

  @spec collect(module()) :: [Route.t()]
  defp collect(router) do
    router
    |> Phoenix.Router.routes()
    |> Enum.filter(&valid_wayfinder_route?/1)
    |> Enum.map(&Route.from_phoenix_route/1)
  end

  # Possible to have routes without controller. Skip them.
  defp valid_wayfinder_route?(%{plug: controller}) when is_atom(controller), do: true
  defp valid_wayfinder_route?(_), do: false
end
