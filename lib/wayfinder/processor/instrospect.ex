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
  @spec source_location(module(), atom()) :: location
  def source_location(module, function_name)
      when is_atom(module) and is_atom(function_name) do
    beam_path = :code.which(module)
    source_location(beam_path, module, function_name)
  end

  defp source_location(beam_path, _module, _function) when not is_list(beam_path),
    do: {nil, nil}

  defp source_location(beam_path, module, function_name) do
    case :beam_lib.chunks(beam_path, [:debug_info]) do
      {:ok, {^module, [debug_info: {:debug_info_v1, :elixir_erl, {_, meta, _}}]}} ->
        extract_location(meta, function_name)

      _ ->
        {nil, nil}
    end
  end

  defp extract_location(%{file: file, definitions: defs}, function_name) do
    {line, _} =
      Enum.find_value(defs, {nil, nil}, fn
        {{^function_name, _arity}, :def, meta, _} ->
          line = Keyword.get(meta, :line)
          {line, true}

        _ ->
          nil
      end)

    {line, Path.relative_to_cwd(file)}
  end

  defp extract_location(_, _), do: {nil, nil}
end
