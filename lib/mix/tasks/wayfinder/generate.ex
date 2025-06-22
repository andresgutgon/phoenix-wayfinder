defmodule Mix.Tasks.Wayfinder.Generate do
  use Mix.Task

  @moduledoc """
  Generates TypeScript routes based on your Phoenix router routes.
  """
  def run(_args) do
    Mix.Task.run("compile")

    router = Application.get_env(:wayfinder_ex, :router)
    otp_app = Application.get_env(:wayfinder_ex, :otp_app)

    case Wayfinder.generate(router, otp_app) do
      :ok ->
        Mix.shell().info("[wayfinder] TypeScript routes generation succeeded")

      {:error, error} ->
        Mix.raise("[wayfinder-error]:\n#{inspect(error, pretty: true)}")
    end
  end
end
