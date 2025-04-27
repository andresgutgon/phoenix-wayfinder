defmodule Mix.Tasks.Wayfinder.Gen.Routes do
  @shortdoc "generates typescript routes with wayfinder."
  use Mix.Task
  alias Wayfinder.Options

  @moduledoc """
  scans your phoenix router and generates actions and routes
  helpers for using in your frontend code based on your phoneix router.

  usage:
      mix wayfinder.gen.routes
      mix wayfinder.gen.routes --skip-actions
      mix wayfinder.gen.routes --skip-routes
  """

  def run(args) do
    Mix.Task.run("app.start")
    opts = Options.parse(args)
    router = Application.get_env(:wayfinder, :router)
    Wayfinder.generate(router, opts)
  end
end
