defmodule Wayfinder.Typescript.Helpers do
  @moduledoc false

  alias Wayfinder.Typescript.BuildParams

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
          required(:optional_args) => boolean(),
          required(:args) => BuildParams.argument(),
          required(:method) => String.t()
        }
  @spec build_http_function(build_function_args()) :: String.t()
  def build_http_function(%{
        action: action,
        args: args,
        optional_args: optional_args,
        method: method
      }) do
    """
    (#{function_args(args, optional_args)}options?: #{function_opts()}}): {
      url: string
      method: '#{method}',
    } => ({
      url: #{action}.url(#{url_args(args)}options),
      method: '#{method}',
    })
    """
  end

  def function_opts(), do: "{ query?: QueryParams, mergeQuery?: QueryParams }"

  def function_args(nil, _), do: ""

  def function_args(args, false), do: "args: #{args}, "

  # Second argument tells arguments are optional
  def function_args(args, true), do: "args?: #{args}, "

  defp url_args(nil), do: ""
  defp url_args(_args), do: "args, "

  defp camelize_name(name) do
    Macro.camelize(name)
    |> then(fn str -> String.downcase(String.first(str)) <> String.slice(str, 1..-1//1) end)
  end
end
