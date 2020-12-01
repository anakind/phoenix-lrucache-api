defmodule LrucacheApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    cache_size = Application.get_env(:lrucache_api, LrucacheApiWeb.Endpoint)[:cache_size]
    children = [
      # Start the Telemetry supervisor
      LrucacheApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LrucacheApi.PubSub},
      # Start the Endpoint (http/https)
      LrucacheApiWeb.Endpoint,
      # Start a worker by calling: LrucacheApi.Worker.start_link(arg)
      # {LrucacheApi.Worker, arg}
      {LruCacheGenServer, cache_size}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LrucacheApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LrucacheApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
