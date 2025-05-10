require Logger

defmodule Wayfinder.Typescript.GroupRoutes do
  @moduledoc """
  Groups a list of `%Wayfinder.Processor.Route{}` entries — all of which belong to the same
  controller and action — into one or more collapsed entries for TypeScript code generation.

  Routes are grouped by shared static path prefix. Within each group, the path with the most
  parameters becomes canonical. All methods across the group are merged. Argument handling is inferred based on the variation in path arity.
  """

  alias Wayfinder.Processor.Route

  @spec call([Route.t()]) :: [Route.t()]
  def call(routes) do
    routes
    |> Enum.group_by(&static_path_prefix/1)
    |> Enum.map(fn {_prefix, group} ->
      build_collapsed_route(group)
    end)
  end

  defp build_collapsed_route(routes) do
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

    Logger.debug("Longest route: #{inspect(longest)}")

    %Route{
      longest
      | methods: merged_methods,
        optional_args: optional_args,
        param_spec_by_method: build_param_spec_by_method(routes)
    }
  end

  defp static_path_prefix(%Route{path: path}) do
    path
    |> String.split("/")
    |> Enum.reject(&String.starts_with?(&1, ":"))
    |> Enum.join("/")
  end

  defp param_count(%Route{path: path}) do
    extract_path_params(path) |> length()
  end

  defp extract_path_params(path) do
    Regex.scan(~r/:([a-zA-Z_]+)/, path)
    |> Enum.map(fn [_, param] -> param end)
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
end
