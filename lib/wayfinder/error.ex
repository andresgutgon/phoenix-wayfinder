defmodule Wayfinder.Error do
  @moduledoc """
  Custom Wayfinder-specific error struct and reason definitions.
  """

  defexception [:message, :reason]

  # -- Centralized reason type -----------------------------------
  @type reason ::
          :processor_failure
          | :router_invalid
          | :otp_app_invalid
          | :route_build_error
          | :tree_build_error
          | :filesystem_error
          | :pattern_invalid
          | :unknown

  @type t :: %__MODULE__{
          message: String.t(),
          reason: reason()
        }

  @doc """
  Creates a new Wayfinder.Error.

  ## Examples

      iex> Wayfinder.Error.new("Failed to build tree", :tree_build_error)
      %Wayfinder.Error{message: "Failed to build tree", reason: :tree_build_error}

  """
  @spec new(String.t(), reason()) :: t()
  def new(message, reason \\ :unknown) do
    %__MODULE__{
      message: message,
      reason: reason
    }
  end
end
