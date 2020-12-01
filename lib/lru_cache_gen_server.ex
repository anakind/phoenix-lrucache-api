defmodule LruCacheGenServer do
  @moduledoc """
    This module implements a simple LRU cache that support storing any type of value,
    implemented as a GenServer backed by ETS using 3 ets tables.
    For using it, you need to start it:
        iex> LruCacheGenServer.start_link(1000)

    ## Using it
        iex> LruCacheGenServer.start_link(1000)
        {:ok, #PID<0.60.0>}
        iex> LruCacheGenServer.put("id", "value")
        :ok
        iex> LruCacheGenServer.get("id")
        "value"
        iex> LruCacheGenServer.put(:k2, 2)
        :ok
        iex> LruCacheGenServer.get(:k2)
        2
        iex> LruCacheGenServer.delete("id")
        :ok

    ## Design
    First ets table `:lrucache_info` save capacity of the cache.

    Second ets set table `:lrucache_stored` save the cache content, each cached content is a tuple of
    {key, time, value} where:
          `key`, `value` are the cached key value pair, the `key` is used as key in this table
          `time` is the last accessed/modified time. This will be updated every access or update

    Third ets ordered_set table `:lru_keys`
    The list is a list of tuple, where each tuple is {time, key} where:
          `time` is the last accessed/modified time, updated every access or update. It is used as key in this table
          `key` refer to the key in the `:lrucache_stored` ets table
    The list is sorted by the `time` asc order, least used is the first of list.
    Every time item evict action required, first of the list is popoff.
    Every time item is touched, new `time` is replaced with old `time`(and item move to the end of list)
  """
  use GenServer

  @doc """
  Creates an LRU cache of the given size
  """
  def start_link(capacity) do
    Agent.start_link(__MODULE__, :init, [capacity], name: __MODULE__)
  end

  @doc """
  Get the value of given key from the cache. If cache already has the key,
  this updates the order of LRU cache.
  """
  def get(key) do
    Agent.get(__MODULE__, __MODULE__, :handle_get, [key])
  end

  @doc """
  Store the given key value pair in the cache. If cache already has the key, the stored
  value is replaced by the new one. This updates the order of LRU cache.
  """
  def put(key, value) do
    Agent.get(__MODULE__, __MODULE__, :handle_put, [key, value])
  end

  @doc """
  Delete the key value pair of given key from the cache.
  """
  def delete(key) do
    Agent.get(__MODULE__, __MODULE__, :handle_delete, [key])
  end

  @doc false
  def init(capacity) do
    :ets.new(:lrucache_info, [:named_table, :protected])
    :ets.new(:lrucache_stored, [:named_table, :protected, :set])
    :ets.new(:lru_keys, [:named_table, :protected, :ordered_set])
    cap = if (capacity > 0), do: capacity, else: 0
    :ets.insert(:lrucache_info, {:capacity, cap})
  end

  @doc false
  def handle_get(state, key) do
    if (:ets.member(:lrucache_stored, key)) do
      newTime = :erlang.unique_integer([:monotonic])
      [{_, oldTime, value}] = :ets.lookup(:lrucache_stored, key)
      delete_existing(oldTime, key)
      insert_new(newTime, key, value)
      value
    else
      nil
    end
  end

  @doc false
  def handle_put(state, key, value) do
    newTime = :erlang.unique_integer([:monotonic])
    capacity = :ets.lookup(:lrucache_info, :capacity)[:capacity]
    size = :ets.info(:lrucache_stored)[:size]

    if size == capacity && !(:ets.member(:lrucache_stored, key)) do
      lru_key_time = :ets.first(:lru_keys)
      [{_, lru_key}] = :ets.lookup(:lru_keys, lru_key_time)
      delete_existing(lru_key_time, lru_key)
      insert_new(newTime, key, value)
    else
      if :ets.member(:lrucache_stored, key) do
        [{_,oldTime,_}] = :ets.lookup(:lrucache_stored, key)
        delete_existing(oldTime, key)
      end
      insert_new(newTime, key, value)
    end
    :ok
  end

  @doc false
  def handle_delete(state, key) do
    if (:ets.member(:lrucache_stored, key)) do
      [{_,oldTime,_}] = :ets.lookup(:lrucache_stored, key)
      delete_existing(oldTime, key)
      :ok
    else
      :not_found
    end
  end

  defp delete_existing(oldTime, oldKey) do
    :ets.delete(:lru_keys, oldTime)
    :ets.delete(:lrucache_stored, oldKey)
  end

  defp insert_new(newTime, newKey, value) do
    :ets.insert(:lru_keys, {newTime, newKey})
    :ets.insert(:lrucache_stored, {newKey, newTime, value})
  end
end