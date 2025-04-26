defmodule WorkbenchWeb.KeyController do
  use WorkbenchWeb, :controller

  def show(conn, _params), do: send_resp(conn, 200, "ok")
  def edit(conn, _params), do: send_resp(conn, 200, "ok")
end
