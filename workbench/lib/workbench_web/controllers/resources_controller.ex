defmodule WorkbenchWeb.ResourcesController do
  use WorkbenchWeb, :controller

  def index(conn, _params) do
    text(conn, "index")
  end

  def show(conn, %{"id" => id}) do
    text(conn, "show #{id}")
  end

  def new(conn, _params) do
    text(conn, "new")
  end

  def create(conn, _params) do
    text(conn, "create")
  end

  def edit(conn, %{"id" => id}) do
    text(conn, "edit #{id}")
  end

  def update(conn, %{"id" => id}) do
    text(conn, "update #{id}")
  end

  def delete(conn, %{"id" => id}) do
    text(conn, "delete #{id}")
  end
end
