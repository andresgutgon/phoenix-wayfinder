defmodule WorkbenchWeb.InvokablePlusController do
  use WorkbenchWeb, :controller

  def index(conn, _params), do: send_resp(conn, 200, "ok")
  def store(conn, _params), do: send_resp(conn, 200, "ok")
end
