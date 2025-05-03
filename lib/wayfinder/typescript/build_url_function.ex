defmodule Wayfinder.Typescript.BuildUrlFunction do
  @moduledoc false

  alias Wayfinder.Typescript.BuildAction

  @spec build(BuildAction.opts()) :: String.t()
  def build(opts) do
    parts = build_params(opts)
    safe_name = opts.safe_name

    """
    #{opts.doc_block}
    #{safe_name}.url = (args: #{opts.param_types}, options?: { query?: QueryParams, mergeQuery?: QueryParams }): string => {
      #{parts.param_parsing}

      #{parts.array_parsing}

      const parsedArgs = {
        #{parts.parsed_args}
      }

      return #{safe_name}.definition.url
        #{parts.replacements}
        .replace(/\/+$/, '') + queryParams(options)
    }
    """
  end

  @spec build_params(BuildAction.opts()) :: map()
  defp build_params(opts) do
    params = opts.path_params

    param_parsing =
      if length(params) == 1 do
        """
        if (typeof args === 'string' || typeof args === 'number') {
          args = { #{hd(params)}: args }
        }
        """
      else
        ""
      end

    array_parsing =
      if params != [] do
        assigns =
          Enum.with_index(params)
          |> Enum.map(fn {p, i} -> "#{p}: args[#{i}]" end)
          |> Enum.join(",\n      ")

        """
        if (Array.isArray(args)) {
          args = {
            #{assigns}
          }
        }
        """
      else
        ""
      end

    parsed_args =
      Enum.map_join(params, ",\n  ", fn param -> "#{param}: args.#{param}" end)

    replacements =
      Enum.map_join(params, "\n    ", fn param ->
        ".replace(':#{param}', parsedArgs.#{param}.toString())"
      end)

    %{
      param_parsing: param_parsing,
      array_parsing: array_parsing,
      parsed_args: parsed_args,
      replacements: replacements
    }
  end
end
