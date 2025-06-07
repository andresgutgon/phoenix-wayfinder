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
    group_by_action_and_path(routes)
    |> order_by_shortest_path()
    |> merge_variants_with_names(opts)
  end

  @spec group_by_action_and_path([PhoenixRoute.t()]) :: [variant()]
  defp group_by_action_and_path(routes) do
    routes
    |> Enum.group_by(fn %{plug: c, plug_opts: a} -> {c, a} end)
    |> Enum.flat_map(fn {{controller, action}, action_routes} ->
      action_routes
      |> Enum.group_by(&static_path_prefix/1)
      |> Map.to_list()
      |> Enum.map(fn {prefix, routes} -> {{controller, action, prefix}, routes} end)
    end)
  end

  @spec order_by_shortest_path([variant()]) :: [indexed_variant()]
  defp order_by_shortest_path(variants) do
    variants
    |> Enum.sort_by(fn {{_controller, _action, _prefix}, routes} ->
      static_segment_count(List.first(routes))
    end)
    |> Enum.with_index()
  end

  @spec merge_variants_with_names([indexed_variant()], Route.phoenix_route_opts()) :: [Route.t()]
  defp merge_variants_with_names(indexed_variants, opts) do
    {result, _used_names} =
      Enum.reduce(indexed_variants, {[], MapSet.new()}, fn
        {{{_controller, action, _prefix}, routes}, _index}, {acc, used_names} ->
          merged_route = merge_route_group(routes, opts)

          base_name =
            if merged_route.alias != Atom.to_string(action),
              do: merged_route.alias,
              else: Atom.to_string(action)

          action_name = unique_action_name(base_name, used_names)
          route_struct = %Route{merged_route | action: String.to_atom(action_name)}
          {[route_struct | acc], MapSet.put(used_names, action_name)}
      end)

    Enum.reverse(result)
  end

  @spec merge_route_group([PhoenixRoute.t()], Route.phoenix_route_opts()) :: Route.t()
  defp merge_route_group(routes, opts) do
    longest = Enum.max_by(routes, &BuildParams.params_count/1)

    route = Route.from_phoenix_route(longest, opts)
    ordered_params = params_order_from_path(longest.path)
    params_by_method = BuildParams.build(routes, ordered_params)

    %Route{
      route
      | methods: get_uniq_methods(routes),
        all_params: build_all_params(params_by_method, ordered_params),
        params_by_method: params_by_method
    }
  end

  @spec get_uniq_methods([PhoenixRoute.t()]) :: [String.t()]
  defp get_uniq_methods(routes) do
    routes
    |> Enum.flat_map(fn route -> Route.normalize_verbs(Map.get(route, :verb)) end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec build_all_params(Route.params_by_method(), [{String.t(), atom()}]) :: [map()]
  defp build_all_params(params_by_method, ordered_params) do
    params_specs =
      params_by_method
      |> Map.values()
      |> Enum.flat_map(& &1)
      |> Enum.group_by(& &1.name)
      |> Enum.map(fn {name, specs} ->
        BuildParams.build_param_spec(name, ordered_params, Enum.any?(specs, & &1.optional))
      end)

    # Sort by order in path
    Enum.sort_by(params_specs, fn spec ->
      Enum.find_index(ordered_params, fn {n, _} -> n == spec.name end) || 999
    end)
  end

  @spec unique_action_name(String.t(), MapSet.t(String.t()), non_neg_integer()) :: String.t()
  defp unique_action_name(base, used_names, n \\ 0) do
    candidate =
      if n == 0, do: base, else: "#{base}#{n + 1}"

    if MapSet.member?(used_names, candidate) do
      unique_action_name(base, used_names, n + 1)
    else
      candidate
    end
  end

  @spec static_path_prefix(PhoenixRoute.t()) :: String.t()
  defp static_path_prefix(route), do: split_static_segments(route) |> Enum.join("/")

  @spec static_segment_count(PhoenixRoute.t()) :: non_neg_integer()
  defp static_segment_count(route), do: split_static_segments(route) |> length()

  @spec split_static_segments(PhoenixRoute.t()) :: [String.t()]
  defp split_static_segments(%{path: path}) do
    path
    |> String.trim("/")
    |> String.split("/")
    |> Enum.reject(&String.starts_with?(&1, ":"))
  end

  @spec params_order_from_path(String.t()) :: [{String.t(), atom()}]
  defp params_order_from_path(path) do
    regex = ~r/(:|\*)([a-zA-Z_]+)/

    Regex.scan(regex, path)
    |> Enum.map(fn
      [_, ":", param] -> {param, :normal}
      [_, "*", param] -> {param, :glob}
    end)
  end
end
