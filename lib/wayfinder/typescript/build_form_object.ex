defmodule Wayfinder.Typescript.BuildFormObject do
  @moduledoc false
  alias Wayfinder.Typescript.{BuildActions, Helpers}

  @spec build(BuildActions.opts()) :: String.t()
  def build(opts) do
    methods = opts.route.methods
    safe_name = opts.safe_name
    param_types = opts.param_types
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
        #{safe_name}Form.#{method_type} = (args: #{param_types}, options?: #{Helpers.function_opts()}): {
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
    const #{safe_name}Form = (args: #{param_types}, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
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
