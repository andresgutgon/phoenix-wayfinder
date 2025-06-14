defmodule Wayfinder.Typescript.BuildUrlFunction do
  @moduledoc false

  alias Wayfinder.Typescript.{BuildActions, Helpers}

  @spec build(BuildActions.opts()) :: String.t()
  def build(opts) do
    args = Helpers.function_args(opts.all_arguments, opts.url_arguments)
    func_opts = Helpers.function_opts()
    safe_name = opts.safe_name

    # Only pass args to buildUrl if the function actually has parameters
    build_url_args =
      if opts.all_arguments == [] do
        "definition: #{safe_name}.definition,\n    options"
      else
        "definition: #{safe_name}.definition,\n    args,\n    options"
      end

    """
    #{safe_name}.url = (#{args} options?: #{func_opts}): WayfinderUrl => {
      return buildUrl({
        #{build_url_args}
      })
    }
    """
  end
end
