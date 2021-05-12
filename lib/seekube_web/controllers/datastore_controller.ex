defmodule SeekubeWeb.DatastoreController do
  use SeekubeWeb, :controller

  action_fallback SeekubeWeb.FallbackController

  def datastore(conn, _params) do
    json(conn, %{id: 4})
  end
end
