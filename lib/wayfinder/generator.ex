defmodule Wayfinder.Generator do
  @moduledoc false
  require Logger

  @dialyzer {:nowarn_function, call: 2}

  alias Wayfinder.{Collections, Options, Error}
  alias Wayfinder.Generator.Typescript

  @spec call(Collections.t(), Options.t()) :: :ok | {:error, Error.t()}
  def call(collections, opts) do
    with :ok <- generate_routes(collections, opts),
         :ok <- generate_actions(collections, opts) do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec generate_routes(Collections.t(), Options.t()) :: :ok | {:error, Error.t()}
  defp generate_routes(%Collections{routes: routes}, _opts) do
    content = Typescript.generate_route_file(routes)
    Logger.debug("Routes Content: #{inspect(content)}")
    :ok
  end

  @spec generate_routes(Collections.t(), Options.t()) :: :ok | {:error, Error.t()}
  defp generate_actions(%Collections{actions: actions}, _opts) do
    content = Typescript.generate_action_file(actions)
    Logger.debug("Actions Content: #{inspect(content)}")
    :ok
  end
end
