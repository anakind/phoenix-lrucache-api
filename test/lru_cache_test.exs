defmodule LruCacheTest do
  use ExUnit.Case
  # doctest LruCache

  test "Basic use case, support any type of object as value" do
#    assert {:ok, _} = LruCacheGenServer.start_link(10)
    initializeCache(10)
    assert :ok == LruCacheGenServer.put(:v1, "test")
    assert "test" == LruCacheGenServer.get(:v1)
    assert nil == LruCacheGenServer.get(2)
    assert :ok == LruCacheGenServer.put(:v1, 1111)
    assert 1111 == LruCacheGenServer.get(:v1)
    assert :ok == LruCacheGenServer.put(2, :test2)
    assert :not_found == LruCacheGenServer.delete(1)
    assert nil == LruCacheGenServer.get(1)
    assert :test2 == LruCacheGenServer.get(2)
    assert :ok == LruCacheGenServer.put("v3", true)
    assert :ok == LruCacheGenServer.put(4.4, 4.4)
    assert true == LruCacheGenServer.get("v3")
    assert 4.4 == LruCacheGenServer.get(4.4)
  end

  test "LRU limit use case" do
#    assert {:ok, _} = LruCacheGenServer.start_link(3)
    initializeCache(3)
    Enum.map(1..3, &LruCacheGenServer.put(&1, "my test #{&1}"))
    assert "my test 1" = LruCacheGenServer.get(1)
    Enum.map(4..6, &LruCacheGenServer.put(&1, "my test #{&1}"))
    assert nil == LruCacheGenServer.get(3)
    assert "my test 4" = LruCacheGenServer.get(4)
  end

  test "more complicated cases`" do
#    assert {:ok, _} = LruCacheGenServer.start_link(3)
    initializeCache(3)
    assert :ok == LruCacheGenServer.put(:a, 1)
    assert 1 == LruCacheGenServer.get(:a)
    assert nil == LruCacheGenServer.get(:b)
    assert :ok == LruCacheGenServer.put(:a, 2)
    assert 2 == LruCacheGenServer.get(:a)
    assert :ok == LruCacheGenServer.put(:a, 1)
    assert :ok == LruCacheGenServer.delete(:a)
    assert :not_found == LruCacheGenServer.delete(:b)
    assert nil == LruCacheGenServer.get(:a)
    assert nil == LruCacheGenServer.get(:b)
    assert :ok == LruCacheGenServer.put(:a, 1)
    assert :ok == LruCacheGenServer.put(:b, 2)
    assert :ok == LruCacheGenServer.put(:c, 3)
    assert 2 == LruCacheGenServer.get(:b)
    assert 3 == LruCacheGenServer.get(:c)
    assert 1 == LruCacheGenServer.get(:a)
    assert nil == LruCacheGenServer.get(:d)
    assert :ok == LruCacheGenServer.put(:d, 4)
    assert nil == LruCacheGenServer.get(:b)
    assert 1 == LruCacheGenServer.get(:a)
    assert 3 == LruCacheGenServer.get(:c)
    assert 4 == LruCacheGenServer.get(:d)
    assert nil == LruCacheGenServer.get(:e)
    assert :ok == LruCacheGenServer.put(:e, 5)
    assert nil == LruCacheGenServer.get(:a)
    assert 3 == LruCacheGenServer.get(:c)
    assert 4 == LruCacheGenServer.get(:d)
    assert 5 == LruCacheGenServer.get(:e)
  end

  defp initializeCache(capacity) do
    {status, result} = LruCacheGenServer.start_link(capacity)
    if status !== :ok do
      {_,pid} = result
      killed = Process.exit(pid, :kill)
      IO.puts "exiting genserver killed, new one created for the test"
      assert {:ok, _} = LruCacheGenServer.start_link(capacity)
    end
  end
end