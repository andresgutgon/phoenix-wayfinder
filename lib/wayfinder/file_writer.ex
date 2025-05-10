defmodule Wayfinder.FileWriter do
  @moduledoc """
  This module is responsible for writing generated Typescript code to
  the destination folder
  """

  alias Wayfinder.{Error, Options}

  @base_path "assets/js"
  @actions_path @base_path <> "/actions"
  @helper_path @base_path <> "/wayfinder"

  @spec write(String.t(), String.t()) :: :ok | {:error, term()}
  def write(controller_path, code) do
    dir = Path.dirname(controller_path)

    with :ok <- File.mkdir_p(dir),
         :ok <- File.write(controller_path, code) do
      :ok
    else
      {:error, reason} ->
        {:error,
         Error.new(
           "Failed to write to #{controller_path} because #{reason}",
           :filesystem_error
         )}
    end
  end

  @spec clean_actions_dir(Options.t()) :: :ok | {:error, Error.t()}
  def clean_actions_dir(%Options{app_root: app_root}) do
    actions_dir = Path.join(app_root, @actions_path)

    case File.rm_rf(actions_dir) do
      {:ok, _} ->
        :ok

      {:error, reason, _file} ->
        {:error, Error.new("Failed to clean actions dir: #{inspect(reason)}", :filesystem_error)}
    end
  end

  @spec build_paths(module(), Options.t()) :: %{
          controller_path: String.t(),
          imports_line: String.t()
        }
  def build_paths(controller, opts) do
    actions_dir = Path.join(opts.app_root, @actions_path)
    parts = get_controller_path_parts(controller)
    constroller_path = Path.join([actions_dir] ++ parts ++ ["index.ts"])

    import_path = build_import_path(constroller_path, opts)
    import_modules = "import { queryParams, type QueryParams } from"
    imports_line = "#{import_modules} '#{import_path}'"

    %{
      controller_path: constroller_path,
      imports_line: imports_line
    }
  end

  @spec copy_typescript_helper(Options.t()) :: :ok | {:error, Error.t()}
  def copy_typescript_helper(opts) do
    target_path = Path.join(opts.app_root, @helper_path)

    try do
      source_file = Path.join([opts.package_root, @helper_path, "index.ts"])
      target_file = Path.join(target_path, "index.ts")

      if File.exists?(target_file) and File.read!(source_file) == File.read!(target_file) do
        :ok
      else
        File.mkdir_p!(target_path)
        File.cp!(source_file, target_file)
        :ok
      end
    rescue
      error ->
        {:error, Error.new("Unexpected error: #{Exception.message(error)}", :filesystem_error)}
    end
  end

  @spec build_import_path(String.t(), Options.t()) :: String.t()
  defp build_import_path(controller_path, %Options{app_root: app_root}) do
    dir = Path.dirname(controller_path)
    relative_from_root = Path.relative_to(dir, Path.join(app_root, @base_path))
    depth = relative_from_root |> Path.split() |> length()

    import_path = Path.join(List.duplicate("..", depth) ++ ["wayfinder"])

    "./" <> import_path
  end

  @spec get_controller_path_parts(module()) :: [String.t()]
  def get_controller_path_parts(controller) do
    controller
    |> Atom.to_string()
    |> String.replace_prefix("Elixir.", "")
    |> String.split(".")
    |> drop_app_namespace()
  end

  defp drop_app_namespace([_app | rest]), do: rest
end
