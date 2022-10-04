defmodule RadioTrackerWeb.AboutController do
  use RadioTrackerWeb, :controller

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end
