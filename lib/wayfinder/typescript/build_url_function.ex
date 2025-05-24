defmodule Wayfinder.Typescript.BuildUrlFunction do
  @moduledoc false

  alias Wayfinder.Typescript.{BuildActions, Helpers}

  @spec build(BuildActions.opts()) :: String.t()
  def build(opts) do
    all_args = opts.route.all_arguments
    args = Helpers.function_args(opts.url_arguments, opts.route.optional_args)
    func_opts = Helpers.function_opts()
    parts = build_params(opts)
    safe_name = opts.safe_name

    arguments_helpers =
      if length(all_args) > 0 do
        """
        #{parts.param_parsing}
        #{parts.array_parsing}
        const parsedArgs = { #{parts.parsed_args} }

        """
      end

    """
    #{safe_name}.url = (#{args} options?: #{func_opts}): string => {
      #{arguments_helpers}
      return (
        #{build_url_with_replacements(safe_name, all_args, opts.route.optional_args)}
      ).replace(/\\/+$/, '') + queryParams(options)
    }
    """
  end

  @spec build_url_with_replacements(String.t(), [String.t()], boolean()) :: String.t()
  defp build_url_with_replacements(name, all_args, optional_args) do
    url = "#{name}.definition.url"

    if length(all_args) > 0 do
      """
      #{url}
        #{build_url_replacements(all_args, optional_args)}
      """
    else
      url
    end
  end

  @spec build_url_replacements([String.t()], boolean()) :: String.t()
  defp build_url_replacements(args, optional_args) do
    Enum.map_join(args, "\n        ", fn arg ->
      if optional_args do
        """
        .replace(':#{arg}', parsedArgs.#{arg}?.toString() ?? '')
        """
      else
        """
        .replace(':#{arg}', parsedArgs.#{arg}.toString())
        """
      end
    end)
  end

  @spec build_params(BuildActions.opts()) :: map()
  defp build_params(opts) do
    args = opts.route.all_arguments
    optional_args = opts.route.optional_args

    %{
      param_parsing: build_param_parsing(args),
      array_parsing: build_array_parsing(args),
      parsed_args: build_parsed_args(args, optional_args)
    }
  end

  @spec build_param_parsing([String.t()]) :: String.t()
  defp build_param_parsing(args) do
    if length(args) == 1 do
      """
      if (typeof args === 'string' || typeof args === 'number') {
        args = { #{hd(args)}: args }
      }
      """
    else
      ""
    end
  end

  @spec build_array_parsing([String.t()]) :: String.t()
  defp build_array_parsing(args) do
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
  end

  @spec build_parsed_args([String.t()], boolean()) :: String.t()
  defp build_parsed_args(args, optional_args) do
    Enum.map_join(args, ",\n  ", fn arg ->
      if optional_args do
        "#{arg}: args?.#{arg}"
      else
        "#{arg}: args.#{arg}"
      end
    end)
  end
end
