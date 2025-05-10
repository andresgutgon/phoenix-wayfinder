defmodule Wayfinder.Typescript.GroupRoutes do
  @moduledoc """
  Groups a list of `%Wayfinder.Processor.Route{}` entries with the **same controller and action**
  into one or more collapsed routes for TypeScript generation.

  ## Purpose

  Phoenix allows defining multiple routes pointing to the same controller/action,
  often with variations in HTTP method or number of path parameters. This module
  processes those variations and groups them appropriately so they can be represented
  as a single (or multiple) function exports in TypeScript.

  ## Grouping Behavior

  The input to this module should be a list of routes that all share the **same
  controller and action**.

  These will be grouped into **one or more** consolidated `%Route{}` entries, based on:

    - Static path prefix (e.g. `/optional` or `/users`)
    - Parameter arity (e.g. `/optional` vs `/optional/:parameter` are collapsed together)

  Each resulting `%Route{}` will be used to generate a separate TypeScript export
  (e.g. `optional`, `optional2`, etc.).

  ## Output

  For each group, a canonical `%Route{}` is built with:

    * `path` - The longest path in the group (most parameters)
    * `methods` - All merged HTTP methods across the group
    * `optional_args` - `true` if some routes in the group have fewer parameters
    * `used_parameters` - Full list of unique parameters across all grouped routes
    * `param_spec_by_method` - Map of method → list of parameters declared in that route

  ## Example

  Given the Phoenix routes:

      get "/optional", OptionalController, :index
      post "/optional/:parameter", OptionalController, :index

  The result will include **one** grouped route:

      %Route{
        path: "/optional/:parameter",
        methods: ["get", "post"],
        optional_args: true,
        used_parameters: ["parameter"],
        param_spec_by_method: %{
          "get" => [],
          "post" => ["parameter"]
        }
      }

  This allows generating:

    - A single `.url()` function with flexible arguments
    - Per-method `.get()` and `.post()` helpers with strict argument requirements

  ## Notes

  - If multiple route paths share the same static prefix but differ in parameter count,
    each unique arity gets its own output entry.
  - This module does **not** group across controller/action boundaries.
  """
  alias Wayfinder.Processor.Route

  @spec call([Route.t()]) :: [Route.t()]
  def call(routes) do
    routes
    |> Enum.group_by(&static_path_prefix/1)
    |> Enum.map(fn {_prefix, group} ->
      longest = Enum.max_by(group, &param_count/1)

      merged_methods =
        group
        |> Enum.flat_map(& &1.methods)
        |> Enum.uniq()
        |> Enum.sort()

      all_params =
        group
        |> Enum.flat_map(&extract_path_params(&1.path))
        |> Enum.uniq()

      optional_args = length(all_params) > param_count(longest)

      %Route{
        longest
        | methods: merged_methods,
          optional_args: optional_args,
          param_spec_by_method: build_param_spec_by_method(group)
      }
    end)
  end

  defp static_path_prefix(%Route{path: path}) do
    path
    |> String.split("/")
    |> Enum.reject(&String.starts_with?(&1, ":"))
    |> Enum.join("/")
  end

  defp param_count(%Route{path: path}) do
    path
    |> String.split("/")
    |> Enum.count(&String.starts_with?(&1, ":"))
  end

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
