use Mix.Config

# Configures the endpoint
config :shrty, Shrty.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "bGiElne5SDlFgnY16uqlyMFP0E4UOaydeiUIYebDJQDIizS2yDwI4cuVdZNwk4wV",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Shrty.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :shrty, :hashids_salt, "abc123youandme"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
