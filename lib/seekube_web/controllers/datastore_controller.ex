defmodule SeekubeWeb.DatastoreController do
  @moduledoc """
  DatastoreController module
  """
  use SeekubeWeb, :controller

  action_fallback SeekubeWeb.FallbackController

  @doc """
  Returns documents by datastore id and a find or where condition
  """
  def datastore(conn, %{
    "id" => id,
    "query" => query
  }) do
    #{:ok, mongo} = name()

    with {:ok, organization} = find_organization(id),
         {:ok, query} <- where_verification(query),
         {clause, query} <- query_clause(query),
         {:ok, query} <- query_constructor(query),
         %{docs: docs} <- execute_query(organization, clause, query) do
      json(conn, docs)
    else
      {:error, msg} -> json(conn, %{error: msg})
    end
  end

  def datastore(conn, _params) do
    json(conn, %{error: "query malformed"})
  end

  defp find_organization(id) do
    case BSON.ObjectId.decode(id) do
      :error ->
        {:error, "#{id} isn't a BSON ObjectID"}

      {:ok, id} ->
        %{docs: docs} = Mongo.find(:mongo, "datastores", %{"_id" => id})
        get_organization(docs)
    end
  end

  defp get_organization([element]) do
    organization =
      Map.get(element, "_organization")
      |> BSON.ObjectId.encode!()

    {:ok, "zds_#{organization}"}
  end

  defp get_organization(_), do: {:error, "no organization found"}

  defp where_verification(query) do
    length = String.length(query)
    query = String.trim(query, "WHERE ")

    if String.length(query) == length do
      {:error, "WHERE is missing"}
    else
      {:ok, query}
    end
  end

  defp query_clause(query) do
    case split(query, "AND") do
      {:AND, query} -> {:AND, query}
      _ -> split(query, "OR")
    end
  end

  defp split(query, atom) do
    query = String.split(query, " #{atom} ")

    if length(query) > 1 do
      {:"#{atom}", query}
    else
      {:WHERE, query}
    end
  end

  defp query_constructor(query) do
    Enum.reduce_while(query, [], fn element, acc ->
      case String.split(element, "=") do
        [field, value] ->
          field = String.trim(field, " ")
          value = String.trim(value, " ")
          {:cont, acc ++ ["#{field}": parse(value)]}

        _ ->
          {:halt, :error}
      end
    end)
    |> case do
      :error ->
        {:error, "Query construction error"}

      query ->
        {:ok, query}
    end
  end

  defp parse(value) do
    cond do
      String.at(value, 0) == "'" and String.ends_with?(value, "'") ->
        String.trim_leading(value, "'")
        |> String.trim_trailing("'")
      Float.parse(value) != :error -> 
        {v, _} = Float.parse(value)
        v
      value == false -> false
      value == true -> true
      true -> value
    end
  end

  defp execute_query(organization, clause, condition) do
    case clause do
      :WHERE ->
        Mongo.find(:mongo, organization, condition)

      :AND ->
        Mongo.find(:mongo, organization, %{"$and" => new_map(condition)})

      :OR ->
        len =
          Keyword.keys(condition)
          |> Enum.dedup()
          |> length()

        if len == length(condition) do
          Mongo.find(:mongo, organization, %{"$or" => new_map(condition)})
        else
          case in_request(condition) do
            :error ->
              :error

            {field, condition} ->
              Mongo.find(:mongo, organization, %{field => %{"$in" => condition}})
          end
        end
    end
  end

  defp new_map(value), do: [Map.new(value)]

  defp in_request(condition) do
    Enum.reduce_while(condition, {nil, []}, fn {field, value}, {_, values} ->
      cond do
        Enum.empty?(values) -> {:cont, {field, [value]}}
        Enum.member?(values, field) -> {:halt, :error}
        true -> {:cont, {field, values ++ [value]}}
      end
    end)
  end

  defimpl Jason.Encoder, for: BSON.ObjectId do
    def encode(val, _opts \\ []) do
      val
      |> BSON.ObjectId.encode!()
    end
  end
end
