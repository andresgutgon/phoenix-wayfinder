defmodule Wayfinder.FileWriter do
  @moduledoc """
  This module is responsible for writing generated Typescript code to
  the destination folder
  """

  alias Wayfinder.{Error, Options, Processor}

  @base_path "assets/js"
  @actions_path @base_path <> "/actions"
  @helper_path @base_path <> "/wayfinder"

  @type paths :: %{
          controller_path: String.t(),
          imports_line: String.t()
        }

  @spec prepare(Options.t()) :: :ok | {:error, Error.t()}
  def prepare(opts) do
    with :ok <- clean_actions_dir(opts),
         :ok <- copy_typescript_helper(opts) do
      :ok
    else
      {:error, error} ->
        {:error, error}
    end
  end

  @spec build_paths(Processor.controller(), Options.t()) :: paths()
  def build_paths(controller, opts) do
    actions_dir = Path.join(opts.app_root, @actions_path)
    constroller_path = Path.join([actions_dir] ++ controller.controller_parts ++ ["index.ts"])

    %{
      controller_path: constroller_path,
      imports_line: build_pathfinder_imports(controller, constroller_path, opts)
    }
  end

  @spec build_pathfinder_imports(Processor.controller(), String.t(), Options.t()) :: String.t()
  defp build_pathfinder_imports(controller, controller_path, opts) do
    import_path = build_import_path(controller_path, opts)

    imports = [
      "queryParams",
      "isCurrentUrl",
      "type RouteQueryOptions",
      "type RouteDefinition",
      "type WayfinderUrl"
    ]

    has_optional_param =
      controller.routes
      |> Enum.flat_map(& &1.all_params)
      |> Enum.any?(fn %{optional: opt} -> opt end)

    imports =
      if has_optional_param do
        ["validateParameters" | imports]
      else
        imports
      end

    "import { #{Enum.join(imports, ", ")} } from '#{import_path}'"
  end

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
  defp clean_actions_dir(%Options{app_root: app_root}) do
    actions_dir = Path.join(app_root, @actions_path)

    case File.rm_rf(actions_dir) do
      {:ok, _} ->
        :ok

      {:error, reason, _file} ->
        {:error, Error.new("Failed to clean actions dir: #{inspect(reason)}", :filesystem_error)}
    end
  end

  @spec copy_typescript_helper(Options.t()) :: :ok | {:error, Error.t()}
  defp copy_typescript_helper(opts) do
    source_dir = Path.join([opts.package_root, @helper_path])
    target_dir = Path.join(opts.app_root, @helper_path)

    try do
      File.mkdir_p!(target_dir)

      Path.wildcard(Path.join(source_dir, "**/*"))
      |> Enum.reject(&String.ends_with?(&1, ".test.ts"))
      |> Enum.each(fn source_file ->
        relative_path = Path.relative_to(source_file, source_dir)
        target_file = Path.join(target_dir, relative_path)

        if File.dir?(source_file) do
          File.mkdir_p!(target_file)
        else
          File.mkdir_p!(Path.dirname(target_file))
          File.cp!(source_file, target_file)
        end
      end)

      :ok
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
end
