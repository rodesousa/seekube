defmodule SeekubeWeb.DocumentController do
  use SeekubeWeb, :controller

  alias Seekube.Datastore
  alias Seekube.Datastore.Document

  action_fallback SeekubeWeb.FallbackController

  def index(conn, _params) do
    documents = Datastore.list_documents()
    render(conn, "index.json", documents: documents)
  end

  def create(conn, %{"document" => document_params}) do
    with {:ok, %Document{} = document} <- Datastore.create_document(document_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.document_path(conn, :show, document))
      |> render("show.json", document: document)
    end
  end

  def show(conn, %{"id" => id}) do
    document = Datastore.get_document!(id)
    render(conn, "show.json", document: document)
  end

  def update(conn, %{"id" => id, "document" => document_params}) do
    document = Datastore.get_document!(id)

    with {:ok, %Document{} = document} <- Datastore.update_document(document, document_params) do
      render(conn, "show.json", document: document)
    end
  end

  def delete(conn, %{"id" => id}) do
    document = Datastore.get_document!(id)

    with {:ok, %Document{}} <- Datastore.delete_document(document) do
      send_resp(conn, :no_content, "")
    end
  end
end
