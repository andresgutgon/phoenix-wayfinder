defmodule Wayfinder.Typescript.Helpers do
  @moduledoc false

  alias Wayfinder.Typescript.BuildParams
  alias Wayfinder.Processor.Route

  @reserved_keywords ~w(
    break case catch class const continue debugger default delete do else
    export extends false finally for function if import in instanceof new null
    return super switch this throw true try typeof var void while with
  )

  @spec safe_method_name(String.t(), String.t()) :: String.t()
  def safe_method_name(name, suffix) do
    name = camelize_name(name)

    cond do
      name in @reserved_keywords ->
        name <> String.capitalize(suffix)

      String.match?(name, ~r/^\d+$/) ->
        suffix <> name

      true ->
        name
    end
  end

  @spec camelize_name(String.t() | atom()) :: String.t()
  def camelize_name(name) do
    name
    |> to_string()
    |> Macro.camelize()
    |> then(fn str -> String.downcase(String.first(str)) <> String.slice(str, 1..-1//1) end)
  end

  @spec clean_typescript(String.t()) :: String.t()
  def clean_typescript(content) do
    content
    |> String.replace(" ,", ",")
    |> String.replace("[ ", "[")
    |> String.replace(", }", " }")
    |> String.replace("} )", "})")
    |> String.replace(" )", ")")
    |> String.replace("( ", "(")
    |> String.replace("\n\n\n", "\n\n")
    |> String.replace(~r/\n{3,}/, "\n\n")
  end

  @type build_function_args :: %{
          required(:action) => String.t(),
          required(:ts_type) => BuildParams.argument(),
          required(:args) => [Route.param_spec()],
          required(:all_args) => [Route.param_spec()],
          required(:method) => String.t()
        }
  @spec build_http_function(build_function_args()) :: String.t()
  def build_http_function(%{
        action: action,
        ts_type: ts_type,
        args: args,
        all_args: all_args,
        method: method
      }) do
    definition_type = build_route_definition_type(method)

    """
    (#{function_args(args, ts_type)}options?: #{function_opts()}): #{definition_type} => ({
      url: #{action}.url(#{url_args(args, all_args)}options).path,
      method: '#{method}',
    })
    """
  end

  def function_opts(), do: "RouteQueryOptions"

  def function_args([], _), do: ""

  @spec function_args([Route.param_spec()], BuildParams.argument()) :: String.t()
  def function_args(args, ts_type) do
    glob_param = Enum.find(args, & &1.glob)
    ts_type_str = "string | number"

    cond do
      args == [] ->
        ""

      # Single glob param: allow both object and array
      glob_param && length(args) == 1 ->
        "args: { #{glob_param.name}: (#{ts_type_str})[] } | (#{ts_type_str})[], "

      # Multiple params, one or more is a glob: only object form
      glob_param ->
        object =
          args
          |> Enum.map(fn
            %{glob: true, name: n} -> "#{n}: (#{ts_type_str})[]"
            %{optional: true, name: n} -> "#{n}?: #{ts_type_str}"
            %{name: n} -> "#{n}: #{ts_type_str}"
          end)
          |> Enum.join(", ")

        "args: { #{object} }, "

      # All required, no globs
      Enum.all?(args, &(!&1.optional)) ->
        "args: #{ts_type}, "

      # Some optional, no globs
      true ->
        "args?: #{ts_type}, "
    end
  end

  @spec build_route_definition_type(String.t() | [String.t()]) :: String.t()
  @spec build_route_definition_type(String.t() | [String.t()], boolean()) :: String.t()
  def build_route_definition_type(methods, with_params \\ false)

  def build_route_definition_type(method, with_params) when is_binary(method) do
    base = if with_params, do: "RouteDefinitionWithParameters", else: "RouteDefinition"
    "#{base}<'#{method}'>"
  end

  def build_route_definition_type(methods, with_params) when is_list(methods) do
    method_types = methods |> Enum.map(&"'#{&1}'") |> Enum.join(", ")
    base = if with_params, do: "RouteDefinitionWithParameters", else: "RouteDefinition"
    "#{base}<[#{method_types}]>"
  end

  @spec url_args([Route.param_spec()], [Route.param_spec()]) :: String.t()
  defp url_args([], []), do: ""
  defp url_args([], _), do: "undefined, "
  defp url_args(_args, _), do: "args, "
end
