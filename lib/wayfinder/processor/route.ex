defmodule Wayfinder.Processor.Route do
  @moduledoc """
  Represents a simplified Phoenix route for TypeScript generation.
  """

  defstruct [:path, :methods, :controller, :action, :name]

  @type t :: %__MODULE__{
          path: String.t(),
          methods: [String.t()],
          controller: module(),
          action: atom(),
          name: String.t() | nil
        }

  @doc """
  Converts a raw %Phoenix.Router.Route{} into a %Wayfinder.Route{}.
  """
  @spec from_phoenix_route(map()) :: t()
  def from_phoenix_route(%{
        path: path,
        plug: controller,
        plug_opts: action,
        helper: helper,
        verb: verb
      }) do
    %__MODULE__{
      path: path,
      controller: controller,
      action: action,
      name: helper,
      methods: normalize_verbs(verb)
    }
  end

  defp normalize_verbs(verb) when is_binary(verb) do
    verb
    |> String.split("|")
    |> Enum.map(&String.downcase/1)
  end

  defp normalize_verbs(verb) when is_atom(verb) do
    [Atom.to_string(verb)]
  end
end
