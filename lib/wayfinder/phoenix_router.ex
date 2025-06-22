defmodule Wayfinder.PhoenixRouter do
  @moduledoc """
  After your Phoenix application is compiled the Typescript routes will be generated
  """

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @after_compile {Wayfinder.PhoenixRouter, :after_compile}
    end
  end

  def after_compile(env, _bytecode) do
    otp_app = Application.get_env(:wayfinder_ex, :otp_app)
    case Wayfinder.generate(env.module, otp_app) do
      :ok -> IO.puts("[wayfinder] routes generation succeeded")
      {:error, reason} -> IO.puts("JS routes generation failed: #{inspect(reason)}")
    end
  end
end
