defmodule Wayfinder.Typescript.DocBlock do
  @moduledoc false

  alias Wayfinder.Processor.Route

  @spec build(Route.t()) :: String.t()
  def build(%Route{} = route) do
    [
      controller_reference(route),
      file_reference(route),
      route_reference(route)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&" * #{&1}")
    |> Enum.join("\n")
    |> then(
      &"""
      /**
      #{&1}
      */
      """
    )
  end

  defp controller_reference(%Route{controller: controller, original_action: original_action}) do
    module_name =
      controller
      |> Atom.to_string()
      |> String.replace_prefix("Elixir.", "")

    "@see #{module_name}::#{original_action}"
  end

  defp file_reference(%Route{file: file, line: line}) when is_binary(file) and is_integer(line),
    do: "@see #{file}:#{line}"

  defp file_reference(_), do: nil

  defp route_reference(%Route{path: path}), do: "@route #{path}"
end
