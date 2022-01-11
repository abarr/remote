# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :remote,
  ecto_repos: [Remote.Repo],
  migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :remote, RemoteWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: RemoteWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Remote.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
