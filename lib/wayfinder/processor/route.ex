defmodule Wayfinder.Processor.Route do
  alias Wayfinder.Processor.Introspect

  @moduledoc """
  Represents a simplified Phoenix route for TypeScript generation.
  """

  alias Wayfinder.Typescript.Helpers, as: Typescript

  defstruct [
    :path,
    :methods,
    :controller,
    :action,
    :alias,
    :line,
    :file,
    all_arguments: [],
    optional_args: false,
    param_spec_by_method: %{}
  ]

  @type t :: %__MODULE__{
          path: String.t(),
          methods: [String.t()],
          controller: module(),
          action: atom(),
          alias: String.t() | nil,
          line: pos_integer() | nil,
          file: String.t() | nil,
          all_arguments: [String.t()],
          optional_args: boolean(),
          param_spec_by_method: %{String.t() => [String.t()]}
        }

  @doc """
  Converts a raw %Phoenix.Router.Route{} into a %Wayfinder.Route{}.
  """
  @spec from_phoenix_route(map()) :: t()
  def from_phoenix_route(%{
        path: path,
        plug: controller,
        plug_opts: action,
        helper: alias,
        verb: verb
      }) do
    {line, file} = Introspect.source_location(controller, action)

    %__MODULE__{
      path: path,
      controller: controller,
      action: action,
      alias: alias,
      line: line,
      file: file,
      methods: normalize_verbs_with_head(verb)
    }
  end

  @doc "Generate a JS-safe method name for controller actions"
  @spec js_method(t()) :: String.t()
  def js_method(%__MODULE__{action: action}) do
    Typescript.safe_method_name(to_string(action), "Method")
  end

  @doc "Return original action name"
  @spec original_js_method(t()) :: String.t()
  def original_js_method(%__MODULE__{action: action}) do
    to_string(action)
  end

  defp normalize_verbs_with_head(verb) do
    normalize_verbs(verb)
    |> then(fn methods ->
      if "get" in methods and "head" not in methods do
        methods ++ ["head"]
      else
        methods
      end
    end)
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
