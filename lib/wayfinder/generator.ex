defmodule Wayfinder.Generator do
  @moduledoc false

  alias Wayfinder.{Collections, Options, Error}

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
    # TODO: Actually generate TypeScript files for routes
    IO.inspect(routes, label: "🚀 Routes to generate")
    :ok
  end

  @spec generate_routes(Collections.t(), Options.t()) :: :ok | {:error, Error.t()}
  defp generate_actions(%Collections{actions: actions}, _opts) do
    # TODO: Actually generate TypeScript files for actions
    IO.inspect(actions, label: "🚀 Actions to generate")
    :ok
  end
end
