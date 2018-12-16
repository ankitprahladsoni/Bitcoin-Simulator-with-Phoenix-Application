defmodule Proj4bWeb.PageController do
  use Proj4bWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
