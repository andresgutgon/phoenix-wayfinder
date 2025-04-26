defmodule WorkbenchWeb.ParameterNameController do
  use WorkbenchWeb, :controller

  def camel(conn, _params), do: send_resp(conn, 200, "ok")
  def studly(conn, _params), do: send_resp(conn, 200, "ok")
  def snake(conn, _params), do: send_resp(conn, 200, "ok")
  def screaming_snake(conn, _params), do: send_resp(conn, 200, "ok")
end

