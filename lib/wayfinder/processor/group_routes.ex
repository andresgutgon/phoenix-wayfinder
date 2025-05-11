defmodule Wayfinder.Processor.GroupRoutes do
  @moduledoc """
  Groups a list of `%Wayfinder.Processor.Route{}` entries — all of which belong to the same
  controller and action — into one or more collapsed entries for TypeScript code generation.

  Routes are grouped by shared static path prefix. Within each group, the path with the most
  parameters becomes canonical. All methods across the group are merged. Argument handling is inferred based on the variation in path parameters arity.
  """

  alias Wayfinder.Processor.Route

  @type variant :: {
          {module(), atom(), String.t()},
          [Wayfinder.Processor.Route.t()]
        }
  @type indexed_variant :: {variant(), non_neg_integer()}

  @spec call([Route.t()]) :: [Route.t()]
  def call(routes) do
    group_by_path(routes)
    |> order_by_shortest_path()
    |> merge_variants_with_names()
  end

  @spec group_by_path([Route.t()]) :: %{{module(), atom()} => [variant()]}
  defp group_by_path(routes) do
    routes
    |> Enum.group_by(fn %Route{controller: c, action: a} = r ->
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

  @spec merge_variants_with_names([indexed_variant()]) :: [Wayfinder.Processor.Route.t()]
  defp merge_variants_with_names(indexed_variants) do
    Enum.map(indexed_variants, fn {{{_controller, action, _prefix}, routes}, index} ->
      merged_route = merge_route_group(routes)
      action_name = desambiguate_action_name(merged_route, action, index)
      %Route{merged_route | action: action_name}
    end)
  end

  defp desambiguate_action_name(route, original_action, index) do
    cond do
      route.alias &&
        route.alias != Atom.to_string(original_action) &&
          String.to_atom(route.alias) != original_action ->
        String.to_atom(route.alias)

      index == 0 ->
        original_action

      true ->
        String.to_atom("#{original_action}#{index + 1}")
    end
  end

  defp merge_route_group(routes) do
    longest = Enum.max_by(routes, &param_count/1)

    merged_methods =
      routes
      |> Enum.flat_map(& &1.methods)
      |> Enum.uniq()
      |> Enum.sort()

    optional_args =
      Enum.any?(routes, fn route ->
        param_count(route) < param_count(longest)
      end)

    %Route{
      longest
      | methods: merged_methods,
        optional_args: optional_args,
        param_spec_by_method: build_param_spec_by_method(routes)
    }
  end

  defp split_static_segments(%Route{path: path}) do
    path
    |> String.trim("/")
    |> String.split("/")
    |> Enum.reject(&String.starts_with?(&1, ":"))
  end

  defp static_path_prefix(route), do: split_static_segments(route) |> Enum.join("/")
  defp static_segment_count(route), do: split_static_segments(route) |> length()

  defp param_count(%Route{path: path}) do
    extract_path_params(path) |> length()
  end

  @spec build_param_spec_by_method([Route.t()]) :: %{String.t() => [String.t()]}
  defp build_param_spec_by_method(group) do
    Enum.reduce(group, %{}, fn route, acc ->
      Enum.reduce(route.methods, acc, fn method, acc2 ->
        method = String.downcase(method)

        params = extract_path_params(route.path)

        Map.update(acc2, method, params, fn existing ->
          Enum.uniq(existing ++ params)
        end)
      end)
    end)
  end

  defp extract_path_params(path) do
    Regex.scan(~r/:([a-zA-Z_]+)/, path)
    |> Enum.map(fn [_, param] -> param end)
  end
end
