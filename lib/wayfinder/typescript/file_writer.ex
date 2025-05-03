require Logger

defmodule Wayfinder.Typescript.FileWriter do
  @moduledoc """
  This module is responsible for writing generated Typescript code to
  the destination folder
  """

  alias Wayfinder.Error

  @spec write(String.t(), String.t(), keyword()) :: :ok | {:error, term()}
  def write(relative_path, code, _opts \\ []) do
    target_path = Path.join(actions_output_dir(), relative_path)

    with :ok <- ensure_directory(Path.dirname(target_path)),
         :ok <- File.write(target_path, code) do
      :ok
    else
      {:error, reason} ->
        {:error,
         Error.new(
           "Failed to write to #{target_path} because #{reason}",
           :filesystem_error
         )}
    end
  end

  @spec controller_path(module()) :: String.t()
  def controller_path(controller) do
    parts =
      controller
      |> Atom.to_string()
      |> String.replace_prefix("Elixir.", "")
      |> String.split(".")
      |> drop_app_namespace()

    Path.join(parts ++ ["index.ts"])
  end

  defp drop_app_namespace([_app | rest]), do: rest

  defp actions_output_dir do
    Path.join(phoenix_root_dir(), "assets/js/actions")
  end

  defp phoenix_root_dir do
    Mix.Project.app_path()
    |> Path.expand()
    |> Path.split()
    |> Enum.take_while(&(&1 != "_build"))
    |> Path.join()
  end

  defp ensure_directory(path) do
    case File.mkdir_p(path) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
