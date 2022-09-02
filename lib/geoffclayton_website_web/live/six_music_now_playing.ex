defmodule GeoffclaytonWebsiteWeb.SixMusicNowPlaying do
  require Logger

  use GeoffclaytonWebsiteWeb, :live_view

  @topic "now_playing"

  def mount(_params, _session, socket) do

    GeoffclaytonWebsiteWeb.Endpoint.subscribe(@topic)

    socket = assign(socket, :now_playing, "...awaiting data...")
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div style="border: 10px solid black; border-radius: 50px; padding: 25px">
      <h1>Now playing: <%= @now_playing %>.</h1>
    </div>
    """
  end

  def handle_info(step, socket) do
    #Logger.debug step.event

    socket = assign(socket, :now_playing, step.event)
    {:noreply, socket}

  end
end

defmodule SixMusic do
  require Logger
  require Periodic
  require String
  @moduledoc """
  Documentation for `SixMusic`.
  """

  def start_job(run_spec) do
    Periodic.start_link(
      # https://elixirforum.com/t/crashes-in-periodic-after-a-code-reload/35865
      run: run_spec,
      # @todo: when a new track is detected, there's no need to be polling every 5 seconds straight away. Maybe wait 30 seconds, then poll
      # every 10 seconds, then at 60 seconds start going every 5 seconds again. Bit unnecessarily fancy I guess, but kinda cool.
      every: :timer.seconds(5)
    )
  end

  defp get_data_from_twitter() do
    source_twitter_account_id = "1405964075360792584"

    url = "https://api.twitter.com/2/users/#{source_twitter_account_id}/tweets"

    bearer_token = "AAAAAAAAAAAAAAAAAAAAAOXYgQEAAAAAIJoS2%2Fz1bmQOYrs8LiyRETq%2Fgag%3DcmeYe8NRoOHjJAcnAKCydHMX9Pwv5MEEA9vslNYkVuNY0TIxvV"

    HTTPoison.get(url, ["Authorization": "Bearer #{bearer_token}"])
  end

  defp extract_body_from_twitter_response(response) do
    case response do
      {:ok, %{status_code: 200, body: body}} -> Poison.decode!(body)
      {:ok, %{status_code: 200}} -> {:error, "No body found"}
      {:ok, %{status_code: 404}} -> "It was a 404"
      {:error, %{reason: reason}} -> "Something bad happened: #{reason}"
    end
  end

  defp extract_artist_from_tweet_text(tweet_text), do: extract_element_from_tweet_text(tweet_text, 2, ":")

  defp extract_song_from_tweet_text(tweet_text), do: extract_element_from_tweet_text(tweet_text, 3, "  🎵 ")

  defp extract_element_from_tweet_text(tweet_text, line_num, replace_str) do
    String.split(tweet_text, "\n")
    |> Enum.at(line_num)
    |> String.replace(replace_str, "")
  end

  @topic "now_playing"

  def get_latest_track() do
    latest_tweet_text = get_data_from_twitter()
    |> extract_body_from_twitter_response()
    |> Map.get("data")
    |> List.first()
    |> Map.get("text")

    artist = extract_artist_from_tweet_text(latest_tweet_text)
    song = extract_song_from_tweet_text(latest_tweet_text)

    #Logger.debug(artist)
    #Logger.debug(song)

    GeoffclaytonWebsiteWeb.Endpoint.broadcast_from(self(), @topic, "#{artist} - #{song}", %{})

    {:ok, artist, song}
  end
end
