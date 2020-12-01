defmodule LrucacheApiWeb.LruCacheController do
  use LrucacheApiWeb, :controller

  @doc """
  POST request to initialize the cache
  """
  def put(conn, %{"key" => key, "value" => value}) do
    json(conn, LruCacheGenServer.put(key, value))
  end

  @doc """
  PUT reqeust to update the value with the key in cache
  """
  def update(conn, %{"key" => key, "value" => value}) do
    put(conn, %{"key" => key, "value" => value})
  end

  @doc """
  Get request to get the value of given key from cache
  """
  def get(conn, %{"key" => key}) do
    value = LruCacheGenServer.get(key)
    cond do
      value == nil ->
        conn |> send_resp(404, "No value found by the key=#{key}")
      true ->
        json(conn, %{key: key, value: LruCacheGenServer.get(key)})
    end
  end

  @doc """
  DELETE request to delete the key from the cache
  """
  def delete(conn, %{"key" => key}) do

    result = LruCacheGenServer.delete(key)
    cond do
      result == :not_found ->
        conn |> send_resp(404, "Key not exist for delete, key=#{key}")
      true ->
        conn |> send_resp(200, "Successfully deleted with key=#{key}")
    end
  end
end
