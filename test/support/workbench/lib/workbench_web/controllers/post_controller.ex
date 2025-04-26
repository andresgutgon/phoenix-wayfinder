defmodule WorkbenchWeb.PostController do
  use WorkbenchWeb, :controller

  def index(conn, _params), do: send_resp(conn, 200, "ok")
  def create(conn, _params), do: send_resp(conn, 200, "ok")
  def store(conn, _params), do: send_resp(conn, 200, "ok")
  def show(conn, _params), do: send_resp(conn, 200, "ok")
  def edit(conn, _params), do: send_resp(conn, 200, "ok")
  def update(conn, _params), do: send_resp(conn, 200, "ok")
  def destroy(conn, _params), do: send_resp(conn, 200, "ok")
end

