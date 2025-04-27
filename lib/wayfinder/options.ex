defmodule Wayfinder.Options do
  @moduledoc """
  Options for Wayfinder route generation.
  """

  alias Wayfinder.Error
  defstruct [:app_root, :package_root]

  @type t :: %__MODULE__{
          package_root: String.t(),
          app_root: String.t()
        }

  @spec build_opts(module(), atom() | nil) :: {:ok, t()} | {:error, Error.t()}
  def build_opts(router, test_opt_app \\ nil) do
    case get_app_root(router, test_opt_app) do
      {:ok, app_root} ->
        {:ok,
         %__MODULE__{
           package_root: package_root_path(),
           app_root: app_root
         }}

      {:error, error} ->
        {:error, Error.new("Failed to get app root: #{inspect(error)}", :filesystem_error)}
    end
  end

  @spec get_app_root(module(), atom() | nil) :: {:ok, String.t()} | {:error, Error.t()}
  def get_app_root(_router, test_opt_app) when is_atom(test_opt_app) do
    validate_and_resolve_app_root(test_opt_app)
  end

  def get_app_root(router, nil) do
    case :application.get_application(router) do
      {:ok, app} ->
        validate_and_resolve_app_root(app)

      :undefined ->
        {:error,
         Wayfinder.Error.new(
           "Could not determine OTP app for #{inspect(router)}",
           :router_invalid
         )}
    end
  end

  defp validate_and_resolve_app_root(app) do
    app_path = Application.app_dir(app)
    app_root = Path.expand("../../../../", app_path)

    if File.exists?(Path.join(app_root, "mix.exs")) do
      {:ok, app_root}
    else
      {:error, Wayfinder.Error.new("Could not validate app root: #{app_root}", :filesystem_error)}
    end
  end

  @spec package_root_path() :: String.t()
  def package_root_path do
    __DIR__
    |> Path.split()
    |> Enum.take_while(&(&1 != "lib"))
    |> Path.join()
  end
end
