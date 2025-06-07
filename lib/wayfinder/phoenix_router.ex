defmodule Wayfinder.PhoenixRouter do
  @moduledoc """
  After your Phoenix application is compiled the Typescript routes will be generated
  """

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @after_compile {Wayfinder.PhoenixRouter, :after_compile}
      @wayfinder_otp_app opts[:otp_app]
    end
  end

  def after_compile(env, _bytecode) do
    # During compilation, the otp_app is set in the module attribute
    # This is needed during tests because the way Earlang works.
    # But in real life apps they don't need to set it
    # because we use :application.get_application(router) which infers the OTP app
    # from the router module
    test_otp_app = Module.get_attribute(env.module, :wayfinder_otp_app)

    case Wayfinder.generate(env.module, test_otp_app) do
      :ok -> IO.puts("JS routes generation succeeded")
      {:error, reason} -> IO.puts("JS routes generation failed: #{inspect(reason)}")
    end
  end
end
