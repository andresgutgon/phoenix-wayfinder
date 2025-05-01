defmodule Wayfinder.Typescript.DocBlock do
  @moduledoc false

  alias Wayfinder.Processor.Route

  @spec build(Route.t()) :: String.t()
  def build(%Route{} = route) do
    [
      see_reference(route),
      file_reference(route),
      route_reference(route)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&(" * #{&1}"))
    |> Enum.join("\n")
    |> then(&"""
    /**
    #{&1}
    */
    """)
  end

  defp see_reference(%Route{name: name, action: action}) when is_binary(name), do:
    "@see #{name}.#{action}"

  defp see_reference(%Route{controller: controller, action: action}) do
    controller
    |> Module.split()
    |> Enum.join(".")
    |> then(&"@see \\#{&1}::#{action}")
  end

  defp file_reference(%Route{file: file, line: line}) when is_binary(file) and is_integer(line), do:
    "@see #{file}:#{line}"

  defp file_reference(_), do: nil

  defp route_reference(%Route{path: path}), do: "@route #{path}"
end

