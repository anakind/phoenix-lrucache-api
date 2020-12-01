# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :lrucache_api, LrucacheApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "978af3zB+AsD0cO6M6vw9ZE+7Ei//3uqsJt1MLk3zlvMbXqmUuNb6CDFKhYmei5c",
  render_errors: [view: LrucacheApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: LrucacheApi.PubSub,
  live_view: [signing_salt: "eeTekBSg"],
  # change your initialized lru cache size, default is set to 20
  cache_size: 20

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
