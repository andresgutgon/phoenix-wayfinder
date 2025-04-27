defmodule WorkbenchWeb.TwoRoutesSameActionController do
  use WorkbenchWeb, :controller

  def same(conn, _params), do: send_resp(conn, 200, "ok")
end

