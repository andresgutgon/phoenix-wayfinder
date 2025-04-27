defmodule Wayfinder.Processor.Namer do
  @moduledoc """
  Utilities for naming and path generation.
  """

  # <- maybe configurable later
  @app_namespace "WorkbenchWeb"

  @doc """
  Converts a controller module into path parts.
  Example:
    WorkbenchWeb.Admin.UserController -> ["Admin", "UserController"]
  """
  @spec module_to_parts(module()) :: [String.t()]
  def module_to_parts(module) do
    module
    |> Atom.to_string()
    |> String.replace_prefix("Elixir.", "")
    |> String.split(".")
    |> strip_app_namespace()
  end

  defp strip_app_namespace([@app_namespace | rest]), do: rest
  defp strip_app_namespace(parts), do: parts
end
