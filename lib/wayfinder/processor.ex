defmodule Wayfinder.Processor do
  @moduledoc false

  alias Phoenix.Router.Route, as: PhoenixRoute
  alias Wayfinder.Error
  alias Wayfinder.Processor.Route
  alias Wayfinder.Processor.GroupRoutes

  @type controller :: %{
          module: module(),
          controller_parts: [String.t()],
          action: atom(),
          routes: [Route.t()]
        }

  @spec call(module()) :: {:ok, [controller()]} | {:error, Error.t()}
  def call(router) do
    try do
      {:ok,
       router
       |> Phoenix.Router.routes()
       |> Enum.filter(&valid_wayfinder_route?/1)
       |> group_by_controller_and_action()}
    rescue
      error ->
        {:error, Error.new(Exception.message(error), :processor_failure)}
    end
  end

  @spec group_by_controller_and_action([PhoenixRoute.t()]) :: [controller()]
  defp group_by_controller_and_action(all_routes) do
    Enum.group_by(all_routes, fn %{plug: controller, plug_opts: action} ->
      {controller, action}
    end)
    |> Enum.map(fn {{controller, action}, routes} ->
      controller_parts = get_controller_path_parts(controller)
      controller_name_action = build_controller_name_action(controller_parts)

      %{
        module: controller,
        controller_parts: controller_parts,
        action: action,
        routes:
          GroupRoutes.call(routes, %{
            controller_parts: controller_parts,
            controller_name_action: controller_name_action
          })
      }
    end)
  end

  @spec build_controller_name_action([String.t()]) :: String.t()
  defp build_controller_name_action(controller_parts) do
    # Ex.: MyHomeController -> my_home
    List.last(controller_parts)
    |> String.replace_suffix("Controller", "")
    |> String.replace(~r/([a-z0-9])([A-Z])/, "\\1_\\2")
    |> String.downcase()
  end

  @spec get_controller_path_parts(module()) :: [String.t()]
  def get_controller_path_parts(controller) do
    controller
    |> Atom.to_string()
    |> String.replace_prefix("Elixir.", "")
    |> String.split(".")
    |> drop_app_namespace()
  end

  defp drop_app_namespace([_app | rest]), do: rest

  # Possible to have routes without controller. Skip them.
  defp valid_wayfinder_route?(%{plug: controller}) when is_atom(controller), do: true
  defp valid_wayfinder_route?(_), do: false
end
