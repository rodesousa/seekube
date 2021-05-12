defmodule SeekubeWeb.DatastoreControllerTest do
  use SeekubeWeb.ConnCase

  alias Seekube.Mongo
  alias Seekube.Mongo.Datastore

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:datastore) do
    {:ok, datastore} = Mongo.create_datastore(@create_attrs)
    datastore
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all datastore", %{conn: conn} do
      conn = get(conn, Routes.datastore_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create datastore" do
    test "renders datastore when data is valid", %{conn: conn} do
      conn = post(conn, Routes.datastore_path(conn, :create), datastore: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.datastore_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.datastore_path(conn, :create), datastore: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update datastore" do
    setup [:create_datastore]

    test "renders datastore when data is valid", %{conn: conn, datastore: %Datastore{id: id} = datastore} do
      conn = put(conn, Routes.datastore_path(conn, :update, datastore), datastore: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.datastore_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, datastore: datastore} do
      conn = put(conn, Routes.datastore_path(conn, :update, datastore), datastore: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete datastore" do
    setup [:create_datastore]

    test "deletes chosen datastore", %{conn: conn, datastore: datastore} do
      conn = delete(conn, Routes.datastore_path(conn, :delete, datastore))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.datastore_path(conn, :show, datastore))
      end
    end
  end

  defp create_datastore(_) do
    datastore = fixture(:datastore)
    %{datastore: datastore}
  end
end
