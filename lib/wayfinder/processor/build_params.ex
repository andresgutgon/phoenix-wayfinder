require Logger

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

  @spec build([PhoenixRoute.t()]) :: Route.params_by_method()
  def build(routes) do
    {counts_acc, totals_acc} = Enum.reduce(routes, {%{}, %{}}, &update_method_acc/2)

    Enum.into(counts_acc, %{}, fn {method, param_counts} ->
      num_routes = Map.get(totals_acc, method, 0)
      {method, build_param_specs_for_method(param_counts, num_routes)}
    end)
  end

  @spec params_count(Route.t() | PhoenixRoute.t()) :: non_neg_integer()
  def params_count(%{path: path}) do
    extract_path_params(path) |> length()
  end

  @spec extract_path_params(String.t()) :: [String.t()]
  def extract_path_params(path) do
    Regex.scan(~r/:([a-zA-Z_]+)/, path)
    |> Enum.map(fn [_, param] -> param end)
  end

  @spec build_param_specs_for_method(
          %{String.t() => non_neg_integer()},
          non_neg_integer()
        ) :: [Route.param_spec()]
  defp build_param_specs_for_method(param_counts, num_routes) do
    param_counts
    |> Enum.map(fn {name, count} ->
      %{
        name: name,
        optional: count < num_routes
      }
    end)
    |> Enum.sort_by(& &1.name)
  end

  @spec update_method_acc(PhoenixRoute.t(), method_acc()) :: method_acc()
  defp update_method_acc(route, method_acc) do
    methods = Route.normalize_verbs(Map.get(route, :verb))
    params = extract_path_params(route.path)

    Enum.reduce(methods, method_acc, fn method, {counts_acc, totals_acc} ->
      prev_counts = Map.get(counts_acc, method, %{})

      new_counts =
        Enum.reduce(params, prev_counts, fn param, acc ->
          Map.update(acc, param, 1, &(&1 + 1))
        end)

      new_counts_acc = Map.put(counts_acc, method, new_counts)
      new_totals_acc = Map.update(totals_acc, method, 1, &(&1 + 1))
      {new_counts_acc, new_totals_acc}
    end)
  end

  defp update_param_counts(counts, params) do
    Enum.reduce(params, counts, fn param, acc ->
      Map.update(acc, param, 1, &(&1 + 1))
    end)
  end
end
