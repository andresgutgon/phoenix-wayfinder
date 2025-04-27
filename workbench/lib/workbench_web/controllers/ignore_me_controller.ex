defmodule WorkbenchWeb.IgnoreMeController do
  use WorkbenchWeb, :controller

  def ignore_me(conn, _params), do: send_resp(conn, 200, "ok")
end
