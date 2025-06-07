defmodule WorkbenchWeb.PageController do
  use WorkbenchWeb, :controller

  def home(conn, _params), do: send_resp(conn, 200, "ok")
  def dashboard(conn, _params), do: send_resp(conn, 200, "ok")
end
