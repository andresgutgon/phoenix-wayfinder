defmodule Wayfinder.Options do
  @moduledoc """
  Options for Wayfinder route generation.
  """

  defstruct [:skip_actions]

  @type t :: %__MODULE__{skip_actions: boolean()}

  @doc """
  Parses CLI args into a %Wayfinder.Options{} struct.
  """
  @spec parse_cli_args([String.t()]) :: t()
  def parse_cli_args(args) do
    %__MODULE__{skip_actions: Enum.member?(args, "--skip-actions")}
  end
end
