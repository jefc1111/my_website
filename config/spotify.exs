import Config

require Logger

if ! System.get_env("SPOTIFY_CLIENT_ID") do
    Logger.warn("optional environment variable SPOTIFY_CLIENT_ID is missing.")
end

if ! System.get_env("SPOTIFY_CLIENT_SECRET") do
    Logger.warn("optional environment variable SPOTIFY_CLIENT_SECRET is missing.")
end

config :radio_tracker, :spotify_api,
  client_id: System.get_env("SPOTIFY_CLIENT_ID") || false,
  client_secret: System.get_env("SPOTIFY_CLIENT_SECRET") || false
