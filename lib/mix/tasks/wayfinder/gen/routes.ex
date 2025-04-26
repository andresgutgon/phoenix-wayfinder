defmodule Mix.Tasks.Wayfinder.Gen.Routes do
  use Mix.Task

  @shortdoc "Generates TypeScript routes with Wayfinder."

  @moduledoc """
  Scans your Phoenix router and generates actions and routes
  helpers for using in your frontend code based on your Phoneix router.

  Usage:
      mix wayfinder.gen.routes
  """

  def run(_args) do
    Mix.shell().info("👋 Hello from Wayfinder! The task is wired up correctly.")
  end
end
