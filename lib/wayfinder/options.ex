require Logger

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
  def build_opts(router, otp_app \\ nil) do
    case get_app_root(router, otp_app) do
      {:ok, app_root} ->
        {:ok,
         %__MODULE__{
           package_root: package_root_path(),
           app_root: app_root
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_app_root(module(), atom()) :: {:ok, String.t()} | {:error, Error.t()}
  defp get_app_root(router, otp_app) do
    case Code.ensure_loaded(router) do
      {:module, _} ->
        validate_and_resolve_app_root(otp_app)

      {:error, e} ->
        {:error,
         Wayfinder.Error.new(
           "Error #{inspect(e, pretty: true)} but router #{inspect(router, pretty: true)}",
           :router_invalid
         )}
    end
  end

  defp validate_and_resolve_app_root(app) when is_atom(app) and not is_nil(app) do
    app_path = Application.app_dir(app)
    app_root = Path.expand("../../../../", app_path)

    if File.exists?(Path.join(app_root, "mix.exs")) do
      {:ok, app_root}
    else
      {:error, Wayfinder.Error.new("Could not validate app root: #{app_root}", :filesystem_error)}
    end
  end

  defp validate_and_resolve_app_root(app) do
    {:error, Wayfinder.Error.new("Invalid otp_app name: #{inspect(app)}", :router_invalid)}
  end

  @spec package_root_path() :: String.t()
  defp package_root_path do
    __DIR__
    |> Path.split()
    |> Enum.take_while(&(&1 != "lib"))
    |> Path.join()
  end
end
