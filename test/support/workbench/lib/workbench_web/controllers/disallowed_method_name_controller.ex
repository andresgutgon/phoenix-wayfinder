defmodule WorkbenchWeb.DisallowedMethodNameController do
  use WorkbenchWeb, :controller

  def delete(conn, _params), do: send_resp(conn, 200, "ok")
  def error_404(conn, _params), do: send_resp(conn, 200, "ok")
end
