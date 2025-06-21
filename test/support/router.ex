
defmodule TestRouter do
  use Phoenix.Router

  @moduledoc """
  A simple test router for RoutesWatcher tests.
  This module exists solely to provide a valid router module for testing
  without depending on the workbench or external dependencies.
  """

  get "/test", TestController, :index
  get "/test/:id", TestController, :show
end
