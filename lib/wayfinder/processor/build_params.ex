defmodule Wayfinder.Processor.BuildParams do
  @moduledoc """
  We get for each route a map of all their arguments and if they are optional or not.

  Example:
  get "/users/:id", UserController, :show
  get "/users/:id/:name", UserController, :show

  In this case `:id` is required and `:name` is optional.
  """

  alias Phoenix.Router.Route, as: PhoenixRoute
  alias Wayfinder.Processor.Route

  @type param_name :: String.t()
  @type http_method :: String.t()
  @type param_count :: non_neg_integer()

  @type counts_acc :: %{http_method => %{param_name => param_count}}
  @type totals_acc :: %{http_method => non_neg_integer()}
  @type method_acc :: {counts_acc, totals_acc}

  @spec build([PhoenixRoute.t()], [{String.t(), atom()}]) :: Route.params_by_method()
  def build(routes, ordered_params) do
    {counts_acc, totals_acc} = Enum.reduce(routes, {%{}, %{}}, &update_method_acc/2)

    Enum.into(counts_acc, %{}, fn {method, param_counts} ->
      {
        method,
        build_param_specs_for_method(
          param_counts,
          ordered_params,
          Map.get(totals_acc, method, 0)
        )
      }
    end)
  end

  @spec build_param_spec(String.t(), [{String.t(), atom()}], any()) :: Route.param_spec()
  def build_param_spec(name, ordered_params, optional_value) do
    type =
      case Enum.find(ordered_params, fn {n, _} -> n == name end) do
        {_, t} -> t
        _ -> :normal
      end

    %{
      name: name,
      optional: optional_value,
      glob: type == :glob
    }
  end

  @spec params_count(Route.t() | PhoenixRoute.t()) :: non_neg_integer()
  def params_count(%{path: path}) do
    extract_path_params(path) |> length()
  end

  @spec build_param_specs_for_method(
          %{String.t() => non_neg_integer()},
          [{String.t(), atom()}],
          non_neg_integer()
        ) :: [Route.param_spec()]
  defp build_param_specs_for_method(param_counts, ordered_params, num_routes) do
    param_specs =
      param_counts
      |> Enum.map(fn {name, count} ->
        build_param_spec(name, ordered_params, count < num_routes)
      end)

    Enum.sort_by(param_specs, fn spec ->
      Enum.find_index(ordered_params, fn {n, _} -> n == spec.name end) || 999
    end)
  end

  @spec extract_path_params(String.t()) :: [{String.t(), atom()}]
  defp extract_path_params(path) do
    regex = ~r/(:|\*)([a-zA-Z_]+)/

    Regex.scan(regex, path)
    |> Enum.map(fn
      [_, ":", param] -> {param, :normal}
      [_, "*", param] -> {param, :glob}
    end)
  end

  @spec update_method_acc(PhoenixRoute.t(), method_acc()) :: method_acc()
  defp update_method_acc(route, method_acc) do
    methods = Route.normalize_verbs(Map.get(route, :verb))
    params = extract_path_params(route.path)

    Enum.reduce(methods, method_acc, fn method, {counts_acc, totals_acc} ->
      prev_counts = Map.get(counts_acc, method, %{})

      new_counts =
        Enum.reduce(params, prev_counts, fn {param, _}, acc ->
          Map.update(acc, param, 1, &(&1 + 1))
        end)

      new_counts_acc = Map.put(counts_acc, method, new_counts)
      new_totals_acc = Map.update(totals_acc, method, 1, &(&1 + 1))
      {new_counts_acc, new_totals_acc}
    end)
  end
end
