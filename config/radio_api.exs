import Config

require Logger

if ! System.get_env("RADIO_API_URL") do
  # Stopped doing a fatal error becaue ElixirLS was crashing in VS Code every time
  # I did not find a bettter workaround.
  # raise("Required RADIO_API_URL is missing.")
  Logger.warn("Optional *very important* RADIO_API_URL is missing.")
end

config :radio_tracker, :radio_api,
  now_playing_url: System.get_env("RADIO_API_URL") || false
