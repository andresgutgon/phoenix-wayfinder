defmodule Wayfinder.Collector do
  @moduledoc """
  Collects routes from a Phoenix router module.
  """

  @doc """
  Collects all routes from the given router module.
  Returns a list of route structs.
  """
  @spec collect(module()) :: list()
  def collect(router) do
    Phoenix.Router.routes(router)
  end
end
