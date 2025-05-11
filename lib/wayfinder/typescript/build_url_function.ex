defmodule Wayfinder.Typescript.BuildUrlFunction do
  @moduledoc false

  alias Wayfinder.Typescript.{BuildActions, Helpers}

  @spec build(BuildActions.opts()) :: String.t()
  def build(opts) do
    args = Helpers.function_args(opts.url_arguments, opts.route.optional_args)
    func_opts = Helpers.function_opts()
    parts = build_params(opts)
    safe_name = opts.safe_name

    """
    #{safe_name}.url = (#{args}, options?: #{func_opts}): string => {
      #{parts.param_parsing}

      #{parts.array_parsing}

      const parsedArgs = { #{parts.parsed_args} }

      return (
        #{safe_name}.definition.url
        #{parts.replacements}
      ).replace(/\\/+$/, '') + queryParams(options)
    }
    """
  end

  @spec build_params(BuildActions.opts()) :: map()
  defp build_params(opts) do
    args = opts.route.all_arguments

    param_parsing =
      if length(args) == 1 do
        """
        if (typeof args === 'string' || typeof args === 'number') {
          args = { #{hd(args)}: args }
        }
        """
      else
        ""
      end

    array_parsing =
      if args != [] do
        assigns =
          Enum.with_index(args)
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
      Enum.map_join(args, ",\n  ", fn arg -> "#{arg}: args.#{arg}" end)

    replacements =
      Enum.map_join(args, "\n        ", fn arg ->
        ".replace(':#{arg}', parsedArgs.#{arg}.toString())"
      end)

    %{
      param_parsing: param_parsing,
      array_parsing: array_parsing,
      parsed_args: parsed_args,
      replacements: replacements
    }
  end
end
