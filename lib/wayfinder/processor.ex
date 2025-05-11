defmodule Wayfinder.Processor do
  @moduledoc false

  alias Wayfinder.Error
  alias Wayfinder.Processor.Route
  alias Wayfinder.Processor.GroupRoutes

  @type controller :: %{module: module(), action: atom(), routes: [Route.t()]}

  @spec call(module()) :: {:ok, [controller()]} | {:error, Error.t()}
  def call(router) do
    try do
      {:ok,
       router
       |> Phoenix.Router.routes()
       |> Enum.filter(&valid_wayfinder_route?/1)
       |> Enum.map(&Route.from_phoenix_route/1)
       |> group_by_controller_and_action()}
    rescue
      error ->
        {:error, Error.new(Exception.message(error), :processor_failure)}
    end
  end

  @spec group_by_controller_and_action([Route.t()]) :: [controller()]
  defp group_by_controller_and_action(all_routes) do
    Enum.group_by(all_routes, fn %Route{controller: controller, action: action} ->
      {controller, action}
    end)
    |> Enum.map(fn {{controller, action}, routes} ->
      %{
        module: controller,
        action: action,
        routes: GroupRoutes.call(routes)
      }
    end)
  end

  # Possible to have routes without controller. Skip them.
  defp valid_wayfinder_route?(%{plug: controller}) when is_atom(controller), do: true
  defp valid_wayfinder_route?(_), do: false
end
