defmodule Wayfinder.Processor.Route do
  alias Wayfinder.Processor.Introspect

  @moduledoc """
  Represents a simplified Phoenix route for TypeScript generation.
  """

  alias Phoenix.Router.Route, as: PhoenixRoute
  alias Wayfinder.Typescript.Helpers, as: Typescript

  defstruct [
    :path,
    :methods,
    :controller,
    :original_action,
    :action,
    :alias,
    :line,
    :file,
    all_params: [],
    params_by_method: %{}
  ]

  @type phoenix_route_opts :: %{
          controller_parts: [String.t()],
          controller_name_action: String.t()
        }
  @type param_spec :: %{
          name: String.t(),
          optional: boolean(),
          glob: boolean()
        }
  @type params_by_method :: %{String.t() => [param_spec()]}

  @type t :: %__MODULE__{
          path: String.t(),
          methods: [String.t()],
          controller: module(),
          action: atom(),
          original_action: atom(),
          alias: String.t(),
          line: pos_integer() | nil,
          file: String.t() | nil,
          all_params: [param_spec()],
          params_by_method: params_by_method()
        }

  @doc """
  Converts a raw %Phoenix.Router.Route{} into a %Wayfinder.Route{}.
  """
  @spec from_phoenix_route(PhoenixRoute.t(), phoenix_route_opts()) :: t()
  def from_phoenix_route(
        %{
          path: path,
          plug: controller,
          plug_opts: action,
          helper: original_alias,
          verb: verb
        },
        opts
      ) do
    {line, file} = Introspect.source_location(controller, action)

    %__MODULE__{
      path: path,
      controller: controller,
      action: action,
      original_action: action,
      alias: build_alias(action, original_alias, opts.controller_name_action),
      line: line,
      file: file,
      methods: normalize_verbs(verb)
    }
  end

  defp build_alias(action, nil, _controller_name_action), do: Atom.to_string(action)

  @spec build_alias(atom(), String.t(), String.t()) :: String.t()
  defp build_alias(action, original_alias, controller_name_action) do
    if original_alias == controller_name_action do
      action |> Atom.to_string()
    else
      original_alias
    end
  end

  @doc "Generate a JS-safe method name for controller actions"
  @spec js_method(t()) :: String.t()
  def js_method(%__MODULE__{action: action}) do
    Typescript.safe_method_name(to_string(action), "Method")
  end

  def normalize_verbs(verb) when is_binary(verb) do
    verb
    |> String.split("|")
    |> Enum.map(&String.downcase/1)
  end

  def normalize_verbs(verb) when is_atom(verb) do
    [verb |> Atom.to_string() |> String.downcase()]
  end
end
