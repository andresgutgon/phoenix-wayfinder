defmodule WorkbenchWeb.PageController do
  use WorkbenchWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
