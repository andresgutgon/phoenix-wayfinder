defmodule Wayfinder.Generator.BuildAction do
  @moduledoc false

  alias Wayfinder.Processor.Route

  def generate(%Route{} = route) do
    safe_name = Route.js_method(route)
    path = route.path
    main_method = Enum.at(route.methods, 0)
    param_types = generate_args_type(path)

    """
    import { queryParams, type QueryParams } from '@/wayfinder'

    /**
     * @see #{doc_reference(route)}
     * @route #{path}
     */
    export const #{safe_name} = (args: #{param_types}, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
      url: string,
      method: '#{String.downcase(main_method)}',
    } => ({
      url: #{safe_name}.url(args, options),
      method: '#{String.downcase(main_method)}',
    })

    #{safe_name}.definition = {
      methods: #{inspect(route.methods)},
      url: '#{path}'
    }

    #{generate_url_function(safe_name, path, param_types)}

    #{generate_http_methods(safe_name, route, param_types)}

    #{generate_form_object(safe_name, route, param_types)}
    """
  end

  defp doc_reference(%Route{name: name, action: action}) when is_binary(name), do: "#{name}.#{action}"

  defp doc_reference(%Route{controller: controller, action: action}) do
    controller
    |> Module.split()
    |> Enum.reverse()
    |> Enum.take(1)
    |> List.first()
    |> then(&"#{&1}.#{action}")
  end

  defp extract_path_params(path) do
    Regex.scan(~r/:([a-zA-Z_]+)/, path)
    |> Enum.map(fn [_, param] -> param end)
  end

  defp generate_args_type(path) do
    params = extract_path_params(path)

    case params do
      [] ->
        "void"

      [param] ->
        "{ #{param}: string | number } | [#{param}: string | number] | string | number"

      _ ->
        flat = Enum.map_join(params, ", ", &"#{&1}: string | number")
        list = Enum.map_join(params, ", ", &"#{&1}")
        "{ #{flat} } | [#{list}]"
    end
  end

  defp generate_url_function(safe_name, path, _type_sig) do
    params = extract_path_params(path)

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

    """
    /**
     * @see #{safe_name}
     * @route #{path}
     */
    #{safe_name}.url = (args: any, options?: { query?: QueryParams, mergeQuery?: QueryParams }): string => {
      #{param_parsing}

      #{array_parsing}

      const parsedArgs = {
        #{parsed_args}
      }

      return #{safe_name}.definition.url
        #{replacements}
        .replace(/\\/+$/, '') + queryParams(options)
    }
    """
  end

  defp generate_http_methods(safe_name, %Route{methods: methods}, type_sig) do
    methods
    |> Enum.map(fn method ->
      """
      /**
       * @see #{safe_name}
       */
      #{safe_name}.#{String.downcase(method)} = (args: #{type_sig}, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
        url: string,
        method: '#{String.downcase(method)}',
      } => ({
        url: #{safe_name}.url(args, options),
        method: '#{String.downcase(method)}',
      })
      """
    end)
    |> Enum.join("\n\n")
  end

  defp generate_form_object(safe_name, %Route{methods: methods, path: path}, type_sig) do
    main_method = Enum.at(methods, 0)

    form_methods =
      methods
      |> Enum.map(fn method ->
        method_type = String.downcase(method)

        call =
          if method_type == "get" do
            "options"
          else
            """
            {
              [options?.mergeQuery ? 'mergeQuery' : 'query']: {
                _method: '#{String.upcase(method)}',
                ...(options?.query ?? options?.mergeQuery ?? {}),
              }
            }
            """
          end

        """
        /**
         * @see #{safe_name}
         * @route #{path}
         */
        #{safe_name}Form.#{method_type} = (args: #{type_sig}, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
          action: string,
          method: '#{form_method_for(method)}',
        } => ({
          action: #{safe_name}.url(args, #{call}),
          method: '#{form_method_for(method)}',
        })
        """
      end)
      |> Enum.join("\n\n")

    """
    /**
     * @see #{safe_name}
     * @route #{path}
     */
    const #{safe_name}Form = (args: #{type_sig}, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
      action: string,
      method: '#{form_method_for(main_method)}',
    } => ({
      action: #{safe_name}.url(args, options),
      method: '#{form_method_for(main_method)}',
    })

    #{form_methods}

    #{safe_name}.form = #{safe_name}Form
    """
  end

  defp form_method_for(http_method) do
    http_method = String.downcase(http_method)

    case http_method do
      "get" -> "get"
      "head" -> "get"
      "options" -> "get"
      _ -> "post"
    end
  end
end
