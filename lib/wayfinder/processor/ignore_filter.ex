defmodule Wayfinder.Processor.IgnoreFilter do
  @moduledoc """
  Handles filtering of Phoenix routes based on ignore patterns configured in the application.

  Supports regex patterns to ignore routes that match specific path patterns.
  Patterns are compiled once and cached for performance.
  """

  alias Phoenix.Router.Route, as: PhoenixRoute
  alias Wayfinder.Error

  @type compiled_patterns :: [Regex.t()]

  @doc """
  Gets compiled ignore patterns from persistent term cache.
  Initializes patterns if not already cached.
  """
  @spec call() :: {:ok, compiled_patterns()} | {:error, Error.t()}
  def call do
    case :persistent_term.get({__MODULE__, :ignore_patterns}, :not_found) do
      :not_found ->
        case compile() do
          {:ok, patterns} ->
            :persistent_term.put({__MODULE__, :ignore_patterns}, patterns)
            {:ok, patterns}

          {:error, error} ->
            {:error, error}
        end

      patterns ->
        {:ok, patterns}
    end
  end

  @spec ignore?(PhoenixRoute.t(), compiled_patterns()) :: boolean()
  def ignore?(_route, []), do: false

  def ignore?(%{path: path}, patterns) do
    Enum.any?(patterns, &Regex.match?(&1, path))
  end

  @spec compile() :: {:ok, compiled_patterns()} | {:error, Error.t()}
  defp compile do
    case get_configured_patterns() do
      {:ok, patterns} ->
        compile_patterns(patterns)

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_configured_patterns() :: {:ok, [String.t()]} | {:error, Error.t()}
  defp get_configured_patterns do
    case Application.get_env(:wayfinder_ex, :ignore_paths, []) do
      patterns when is_list(patterns) ->
        if Enum.all?(patterns, &is_binary/1) do
          {:ok, patterns}
        else
          message = "ignore_paths configuration must be a list of strings"
          {:error, Error.new(message, :pattern_invalid)}
        end

      pattern when is_binary(pattern) and pattern != "" ->
        {:ok, [pattern]}

      pattern when is_binary(pattern) and pattern == "" ->
        {:ok, []}

      invalid ->
        message =
          "ignore_paths configuration must be a string or list of strings, got: #{inspect(invalid)}"

        {:error, Error.new(message, :pattern_invalid)}
    end
  end

  @spec compile_patterns([String.t()]) :: {:ok, compiled_patterns()} | {:error, Error.t()}
  defp compile_patterns(patterns) do
    case compile_all_patterns(patterns, []) do
      {:ok, compiled} ->
        {:ok, compiled}

      {:error, invalid_pattern} ->
        message = "Invalid regex pattern in ignore_paths: #{invalid_pattern}"
        {:error, Error.new(message, :pattern_invalid)}
    end
  end

  @spec compile_all_patterns([String.t()], compiled_patterns()) ::
          {:ok, compiled_patterns()} | {:error, String.t()}
  defp compile_all_patterns([], acc), do: {:ok, Enum.reverse(acc)}

  defp compile_all_patterns([pattern | rest], acc) when is_binary(pattern) and pattern != "" do
    case Regex.compile(pattern) do
      {:ok, compiled_regex} ->
        compile_all_patterns(rest, [compiled_regex | acc])

      {:error, _} ->
        {:error, pattern}
    end
  end

  defp compile_all_patterns([_invalid | _rest], _acc) do
    {:error, "non-string pattern"}
  end
end
