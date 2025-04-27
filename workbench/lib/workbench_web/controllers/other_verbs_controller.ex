defmodule WorkbenchWeb.OtherVerbsController do
  use WorkbenchWeb, :controller

  def head_action(conn, _params) do
    conn
    |> put_resp_header("x-custom-header", "head-response")
    |> send_resp(200, "")
  end

  def options_action(conn, _params) do
    conn
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "Content-Type, Authorization")
    |> send_resp(200, "")
  end

  def match_action(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> json(%{method: conn.method, message: "Match action called"})
  end

  def match_with_params(conn, params) do
    conn
    |> put_resp_content_type("application/json")
    |> json(%{method: conn.method, params: params, message: "Match with params action called"})
  end
end
