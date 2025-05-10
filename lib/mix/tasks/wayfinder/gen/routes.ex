defmodule Mix.Tasks.Wayfinder.Gen.Routes do
  @shortdoc "generates typescript routes with wayfinder."
  use Mix.Task

  @moduledoc """
  scans your phoenix router and generates actions and routes
  helpers for using in your frontend code based on your phoneix router.

  usage:
      mix wayfinder.gen.routes
      mix wayfinder.gen.routes --skip-actions (Useless unless we implement routes in the futture)
  """

  def run(args) do
    Mix.Task.run("app.start")
    router = Application.get_env(:wayfinder, :router)
    Wayfinder.generate(router, args)
  end
end
