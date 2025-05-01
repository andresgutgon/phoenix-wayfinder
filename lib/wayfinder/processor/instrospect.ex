require Logger

defmodule Wayfinder.Processor.Introspect do
  @moduledoc """
  Extracts `{line, file}` metadata for a given controller and action.

  Used to emit `@see` references for frontend route/action generators.
  """

  @type location :: {line :: pos_integer(), file :: binary()} | nil

  @doc """
  Returns the `{line, file}` where the given controller `module` and `action` are defined.

  Returns `nil` if not available.

  ## Example

      iex> source_location(MyAppWeb.PostController, :index)
      {15, "/app/lib/my_app_web/controllers/post_controller.ex"}
  """
  @spec source_location(module(), atom()) :: location | nil
  def source_location(module, function_name) when is_atom(module) and is_atom(function_name) do
    beam_path = :code.which(module)

    Logger.info("Beam path: #{inspect(beam_path)}")
    Logger.info("Chunks: #{inspect(:beam_lib.chunks(beam_path, [:debug_info]))}")

    if is_binary(beam_path) do
      case :beam_lib.chunks(beam_path, [:debug_info]) do
        {:ok,
         {_,
          [
            debug_info:
              {:debug_info_v1, :elixir_erl, {:elixir_v1, %{file: file, definitions: defs}, _}}
          ]}} ->
          Enum.find_value(defs, fn
            {{^function_name, _arity}, :def, meta, _} ->
              line = Keyword.get(meta, :line)
              if line, do: {file, line}

            _ ->
              nil
          end)

        _ ->
          nil
      end
    else
      nil
    end
  end
end
