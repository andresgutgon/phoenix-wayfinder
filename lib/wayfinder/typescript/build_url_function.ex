defmodule Wayfinder.Typescript.BuildUrlFunction do
  @moduledoc false

  alias Wayfinder.Typescript.{BuildActions, Helpers}
  alias Wayfinder.Processor.Route

  @spec build(BuildActions.opts()) :: String.t()
  def build(opts) do
    all_args = opts.all_arguments
    optional = Enum.any?(all_args, & &1.optional)
    args = Helpers.function_args(all_args, opts.url_arguments)
    func_opts = Helpers.function_opts()
    safe_name = opts.safe_name
    parts = build_params(opts, optional, safe_name)

    arguments_helpers =
      if length(all_args) > 0 do
        """
        #{parts.param_parsing}
        #{parts.array_parsing}
        #{parts.validate_check}
        const parsedArgs = { #{parts.parsed_args} }

        """
      end

    """
    #{safe_name}.url = (#{args} options?: #{func_opts}): string => {
      #{arguments_helpers}
      const baseUrl = #{build_url_with_replacements(safe_name, all_args)}
      const cleanUrl = baseUrl.replace(/\\/+$/, '') || '/'
      return cleanUrl + queryParams(options)
    }
    """
  end

  @spec build_url_with_replacements(String.t(), [String.t()]) :: String.t()
  defp build_url_with_replacements(name, all_args) do
    url = "#{name}.definition.url"

    if length(all_args) > 0 do
      """
      #{url}
        #{build_url_replacements(all_args)}
      """
    else
      url
    end
  end

  @spec build_url_replacements([Route.param_spec()]) :: String.t()
  defp build_url_replacements(args) do
    accessor = "."

    Enum.map_join(args, "\n        ", fn arg ->
      if arg.glob do
        ".replace('/*#{arg.name}', Array.isArray(parsedArgs#{accessor}#{arg.name}) ? `/${parsedArgs#{accessor}#{arg.name}.join('/')}` : '')"
      else
        ".replace(':#{arg.name}', (parsedArgs#{accessor}#{arg.name} != null ? parsedArgs#{accessor}#{arg.name}.toString() : ''))"
      end
    end)
  end

  defp build_params(opts, optional, safe_name) do
    args = opts.all_arguments

    %{
      param_parsing: build_param_parsing(args, safe_name),
      array_parsing: build_array_parsing(args),
      validate_check: build_validate_check(args),
      parsed_args: build_parsed_args(args, optional)
    }
  end

  @spec build_param_parsing([Route.param_spec()], String.t()) :: String.t()
  defp build_param_parsing(args, safe_name) do
    if Enum.all?(args, & &1.optional) do
      template_ref = "#{safe_name}.definition.url"

      """
      if (args == null) {
        let basePath = #{template_ref};
        #{Enum.map_join(Enum.reverse(args), "\n", fn param -> "basePath = basePath.replace(/\\/:#{param.name}(\\?)?$/, '');" end)}
        return basePath || '/';
      }
      """
    else
      if length(args) == 1 do
        """
        if (args == null) return #{safe_name}.definition.url;
        if (typeof args === 'string' || typeof args === 'number') {
          args = { #{hd(args).name}: args }
        }
        """
      else
        """
        if (args == null) return #{safe_name}.definition.url;
        """
      end
    end
  end

  @spec build_array_parsing([Route.param_spec()]) :: String.t()
  defp build_array_parsing(args) do
    cond do
      length(args) > 1 ->
        assigns =
          Enum.with_index(args)
          |> Enum.map(fn {p, i} -> "#{p.name}: args[#{i}]" end)
          |> Enum.join(",\n      ")

        """
        args = args || {};
        if (Array.isArray(args)) {
          args = {
            #{assigns}
          }
        }
        """

      length(args) == 1 ->
        # Handle single argument case where args could be [value] array
        param = hd(args)

        """
        if (Array.isArray(args)) {
          args = { #{param.name}: args[0] }
        }
        """

      true ->
        ""
    end
  end

  @spec build_validate_check([Route.param_spec()]) :: String.t()
  defp build_validate_check(args) do
    optional_params = Enum.filter(args, & &1.optional)

    if optional_params != [] do
      names =
        optional_params
        |> Enum.map(&~s|"#{&1.name}"|)
        |> Enum.join(", ")

      "validateParameters(args, [#{names}])"
    else
      ""
    end
  end

  @spec build_parsed_args([Route.param_spec()], boolean()) :: String.t()
  defp build_parsed_args(args, optional) do
    Enum.map_join(args, ",\n  ", fn arg ->
      if optional do
        "#{arg.name}: args?.#{arg.name}"
      else
        "#{arg.name}: args.#{arg.name}"
      end
    end)
  end
end
