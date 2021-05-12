defmodule SeekubeWeb.PageController do
  use SeekubeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
