defmodule Wayfinder.Options do
  @moduledoc """
  Options for Wayfinder route generation.
  """

  defstruct [
    :skip_actions,
    :skip_routes
  ]

  @type t :: %__MODULE__{
          skip_actions: boolean(),
          skip_routes: boolean()
        }

  @doc """
  Parses CLI args into a %Wayfinder.Options{} struct.
  """
  @spec parse([String.t()]) :: t()
  def parse(args) do
    %__MODULE__{
      skip_actions: Enum.member?(args, "--skip-actions"),
      skip_routes: Enum.member?(args, "--skip-routes")
    }
  end
end
