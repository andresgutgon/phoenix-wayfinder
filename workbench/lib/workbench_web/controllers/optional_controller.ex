defmodule WorkbenchWeb.OptionalController do
  use WorkbenchWeb, :controller

  def optional(conn, _params), do: send_resp(conn, 200, "ok")
  def many_optional(conn, _params), do: send_resp(conn, 200, "ok")
end
