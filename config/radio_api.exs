import Config

require Logger

if ! System.get_env("RADIO_API_URL") do
    raise "Required environment variable RADIO_API_URL is missing."
end

config :radio_tracker, :radio_api,
  now_playing_url: System.get_env("RADIO_API_URL") || false
