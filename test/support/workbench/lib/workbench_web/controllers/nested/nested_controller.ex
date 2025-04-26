defmodule WorkbenchWeb.Nested.NestedController do
  use WorkbenchWeb, :controller

  def nested(conn, _params), do: send_resp(conn, 200, "ok")
end

