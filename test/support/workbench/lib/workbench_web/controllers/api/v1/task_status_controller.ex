defmodule WorkbenchWeb.Api.V1.TaskStatusController do
  use WorkbenchWeb, :controller

  def index(conn, _params), do: send_resp(conn, 200, "ok")
end

