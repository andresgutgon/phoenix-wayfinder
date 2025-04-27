defmodule Wayfinder.Generator.NamedRoute do
  @moduledoc false

  alias Wayfinder.Processor.Route

  defp generate_function(route) do
    safe_name = Route.named_method(route)
    path = route.path
    main_method = Enum.at(route.methods, 0)

    method_helpers =
      route.methods
      |> Enum.map(fn method ->
        """
        #{safe_name}.#{String.downcase(method)} = (args, options) => ({
          url: #{safe_name}.url(args, options),
          method: '#{String.downcase(method)}'
        })
        """
      end)
      |> Enum.join("\n\n")

    form_helpers =
      route.methods
      |> Enum.map(fn method ->
        """
        #{safe_name}Form.#{String.downcase(method)} = (args, options) => ({
          action: #{safe_name}.url(args, #{build_form_query(method, "options")}),
          method: '#{form_method_for(method)}'
        })
        """
      end)
      |> Enum.join("\n\n")

    """
    /**
     * @see #{route.controller}.#{route.action}
     * @route #{path}
     */
    export const #{safe_name} = (args, options) => ({
      url: #{safe_name}.url(args, options),
      method: '#{main_method}'
    })

    #{safe_name}.definition = {
      methods: #{inspect(route.methods)},
      url: '#{path}'
    }

    #{safe_name}.url = (args, options) => {
      // TODO: replace path parameters if needed
      return #{safe_name}.definition.url + queryParams(options)
    }

    #{method_helpers}

    const #{safe_name}Form = (args, options) => ({
      action: #{safe_name}.url(args, options),
      method: '#{form_method_for(main_method)}'
    })

    #{form_helpers}

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

  defp build_form_query(http_method, options_var \\ "options") do
    http_method = String.downcase(http_method)

    case http_method do
      "get" ->
        options_var

      "head" ->
        """
        {
          [#{options_var}?.mergeQuery ? 'mergeQuery' : 'query']: {
            _method: 'HEAD',
            ...(#{options_var}?.query ?? #{options_var}?.mergeQuery ?? {}),
          }
        }
        """

      _ ->
        """
        {
          [#{options_var}?.mergeQuery ? 'mergeQuery' : 'query']: {
            _method: '#{String.upcase(http_method)}',
            ...(#{options_var}?.query ?? #{options_var}?.mergeQuery ?? {}),
          }
        }
        """
    end
  end
end
