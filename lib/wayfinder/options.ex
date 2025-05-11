defmodule Wayfinder.Options do
  @moduledoc """
  Options for Wayfinder route generation.
  """

  alias Wayfinder.Error
  defstruct [:skip_actions, :app_root, :package_root]

  @type t :: %__MODULE__{
          skip_actions: boolean(),
          package_root: String.t(),
          app_root: String.t()
        }

  @doc """
  Build options for the Wayfinder generator. You can pass in a list of command-line arguments and also get the app route based on your router module.
  """
  @spec build_opts(module(), [String.t()] | nil) :: {:ok, t()} | {:error, Error.t()}
  def build_opts(router, args) do
    case get_app_root(router) do
      {:ok, app_root} ->
        {:ok,
         %__MODULE__{
           package_root: package_root_path(),
           app_root: app_root,
           skip_actions: Enum.member?(args, "--skip-actions")
         }}

      {:error, error} ->
        {:error, Error.new("Failed to get app root: #{inspect(error)}", :filesystem_error)}
    end
  end

  @spec get_app_root(module()) :: {:ok, String.t()} | {:error, Error.t()}
  def get_app_root(router) do
    case :application.get_application(router) do
      {:ok, app} ->
        app_path = Application.app_dir(app)
        app_root = Path.expand("../../../../", app_path)

        if File.exists?(Path.join(app_root, "mix.exs")) do
          {:ok, app_root}
        else
          {:error,
           Wayfinder.Error.new("Could not validate app root: #{app_root}", :filesystem_error)}
        end

      :undefined ->
        {:error,
         Wayfinder.Error.new(
           "Could not determine OTP app for #{inspect(router)}",
           :router_invalid
         )}
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
