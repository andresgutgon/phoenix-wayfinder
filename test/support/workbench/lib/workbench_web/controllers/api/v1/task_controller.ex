defmodule WorkbenchWeb.Api.V1.TaskController do
  use WorkbenchWeb, :controller

  def tasks(conn, _params), do: send_resp(conn, 200, "ok")
end

