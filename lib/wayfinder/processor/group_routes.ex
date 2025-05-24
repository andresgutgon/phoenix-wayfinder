defmodule Wayfinder.Processor.GroupRoutes do
  @moduledoc """
  Handle `%Phoenix.Router.Route{}` entries —
  These are the steps in this module.

  1. Group routes by their controller and action.
  2. Routes are grouped by shared static path prefix. Ex.: `/users/:id` and `users/:id/:name`
  3. Within each group, the path with the most parameters becomes canonical. Ex.: `/users/:id/:name`
  4. Routes are sorted with the shortest path first.
  5. All methods across the group are merged.
  6. Argument handling is inferred based on the variation in path parameters arity.
  7. We get for each route a map of all their arguments and if they are optional or not.

  Also this is my best shot to simulating Phoenix has built-in support for optional parameters
  in the router. This is not a feature of Phoenix but if 2 routes are declared with 2 paths like this

  ```elixir
  get "/users/:id", UserController, :show
  get "/users/:id/:name", UserController, :show
  ```

  This is the logic here:
  We assume `:name` is optional and `:id` is required.

  We do all of this to generate a compresive TypeScript route definition

  The final out is a list of `%Wayfinder.Processor.Route{}` structs
  """

  alias Phoenix.Router.Route, as: PhoenixRoute
  alias Wayfinder.Processor.{BuildParams, Route}

  @type variant :: {{module(), atom(), String.t()}, [PhoenixRoute.t()]}
  @type indexed_variant :: {variant(), non_neg_integer()}

  @spec call([PhoenixRoute.t()], Route.phoenix_route_opts()) :: [Route.t()]
  def call(routes, opts) do
    group_by_path(routes)
    |> order_by_shortest_path()
    |> merge_variants_with_names(opts)
  end

  @spec group_by_path([PhoenixRoute.t()]) :: %{{module(), atom()} => [variant()]}
  defp group_by_path(routes) do
    routes
    |> Enum.group_by(fn %{plug: c, plug_opts: a} = r ->
      {c, a, static_path_prefix(r)}
    end)
    |> Enum.group_by(fn {{controller, action, _}, _routes} ->
      {controller, action}
    end)
  end

  @spec order_by_shortest_path(%{{module(), atom()} => [variant()]}) :: [{variant(), integer()}]
  defp order_by_shortest_path(grouped_variants) do
    grouped_variants
    |> Enum.flat_map(fn {_key, variants} -> variants end)
    |> Enum.sort_by(fn {{_controller, _action, _prefix}, routes} ->
      static_segment_count(List.first(routes))
    end)
    |> Enum.with_index()
  end

  @spec merge_variants_with_names([indexed_variant()], Route.phoenix_route_opts()) :: [Route.t()]
  defp merge_variants_with_names(indexed_variants, opts) do
    Enum.map(indexed_variants, fn {{{_controller, action, _prefix}, routes}, index} ->
      merged_route = merge_route_group(routes, opts)
      action_name = desambiguate_action_name(merged_route, action, index)
      %Route{merged_route | action: action_name}
    end)
  end

  @spec merge_route_group([PhoenixRoute.t()], Route.phoenix_route_opts()) :: Route.t()
  defp merge_route_group(routes, opts) do
    longest = Enum.max_by(routes, &BuildParams.params_count/1)

    route = Route.from_phoenix_route(longest, opts)
    %Route{
      route
      | methods: get_uniq_methods(routes),
        all_arguments: BuildParams.extract_path_params(route.path),
        optional_args: optional_args?(routes, route),
        params_by_method: BuildParams.build(routes)
    }
  end

  @spec optional_args?([PhoenixRoute.t()], Route.t()) :: boolean()
  defp optional_args?(routes, route) do
    Enum.any?(routes, fn phx_route ->
      BuildParams.params_count(phx_route) < BuildParams.params_count(route)
    end)
  end

  @spec get_uniq_methods([PhoenixRoute.t()]) :: [String.t()]
  defp get_uniq_methods(routes) do
    routes
    |> Enum.flat_map(fn route -> Route.normalize_verbs(Map.get(route, :verb)) end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec desambiguate_action_name(Route.t(), atom(), non_neg_integer()) :: atom()
  defp desambiguate_action_name(route, original_action, index) do
    cond do
      route.alias != Atom.to_string(original_action) ->
        String.to_atom(route.alias)

      index == 0 ->
        original_action

      true ->
        String.to_atom("#{original_action}#{index + 1}")
    end
  end

  @spec static_path_prefix(PhoenixRoute.t()) :: String.t()
  defp static_path_prefix(route), do: split_static_segments(route) |> Enum.join("/")

  @spec static_segment_count(PhoenixRoute.t()) :: non_neg_integer()
  defp static_segment_count(route), do: split_static_segments(route) |> length()

  @spec split_static_segments(PhoenixRoute.t()) :: [String.t()]
  defp split_static_segments(%{path: path}) do
    # TODO: Handle Phoenix route glob operator. Ex.: `*param`
    path
    |> String.trim("/")
    |> String.split("/")
    |> Enum.reject(&String.starts_with?(&1, ":"))
  end
end
