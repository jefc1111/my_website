# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :radio_tracker,
  ecto_repos: [RadioTracker.Repo]

# Configures the endpoint
config :radio_tracker, RadioTrackerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tiiIH9yAeMwvzaWgf7C8D0I/3l22+Tsz5Y3vEI6VbYx12mHL7R24FdTf1rbd0Lci",
  render_errors: [view: RadioTrackerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RadioTracker.PubSub,
  live_view: [signing_salt: "TasqEvgY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
]

config :dart_sass,
  version: "1.49.11",
  default: [
    args: ~w(--load-path=../deps/bulma css:../priv/static/assets),
    cd: Path.expand("../assets", __DIR__)
  ]

config :radio_tracker, RadioTracker.Mailer,
  adapter: Swoosh.Adapters.Local

config :flop, repo: RadioTracker.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
import_config "twitter.exs"
import_config "spotify.exs"
