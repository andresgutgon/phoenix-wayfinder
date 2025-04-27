defmodule Wayfinder.Processor.Route do
  @moduledoc """
  Represents a simplified Phoenix route for TypeScript generation.
  """

  alias Wayfinder.Typescript.Helpers, as: Typescript

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

  @doc "Generate a JS-safe method name for controller actions"
  @spec js_method(t()) :: String.t()
  def js_method(%__MODULE__{action: action}) do
    Typescript.safe_method_name(to_string(action), "Method")
  end

  #Phoenix helper names are not always valid JS method names.
  @spec named_method(t()) :: String.t() | nil
  def named_method(%__MODULE__{name: nil}), do: nil

  @doc "Generate a JS-safe method name for named routes"
  @spec named_method(t()) :: String.t()
  def named_method(%__MODULE__{name: name}) do
    Typescript.safe_method_name(last_named_segment(name), "Route")
  end

  @doc "Return original action name"
  @spec original_js_method(t()) :: String.t()
  def original_js_method(%__MODULE__{action: action}) do
    to_string(action)
  end

  defp last_named_segment(name) when is_binary(name) do
    name
    |> String.split(".")
    |> List.last()
  end

  defp normalize_verbs(verb) when is_binary(verb) do
    verb
    |> String.split("|")
    |> Enum.map(&String.downcase/1)
  end

  defp normalize_verbs(verb) when is_atom(verb) do
    [verb |> Atom.to_string() |> String.downcase()]
  end
end
