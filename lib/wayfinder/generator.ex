defmodule Wayfinder.Generator do
  @moduledoc false
  require Logger

  @dialyzer {:nowarn_function, call: 2}

  alias Wayfinder.{Collections, Options, Error}
  alias Wayfinder.Typescript.BuildAction

  @spec call(Collections.t(), Options.t()) :: :ok | {:error, Error.t()}
  def call(collections, opts) do
    with :ok <- generate_actions(collections, opts) do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec generate_actions(Collections.t(), Options.t()) :: :ok | {:error, Error.t()}
  defp generate_actions(%Collections{actions: actions}, _opts) do
    last_action = Enum.at(actions, -1)
    ts_code = BuildAction.generate(last_action)
    # Logger.info("Generated TypeScript code:\n\n#{ts_code}")
    :ok
  end
end
