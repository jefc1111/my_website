defmodule GeoffclaytonWebsite.SixMusicTwitterPoller do
  alias GeoffclaytonWebsite.Track

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
    source_twitter_account_id = Application.get_env(:geoffclayton_website, :six_music_twitter)[:account_id]

    url = "https://api.twitter.com/2/users/#{source_twitter_account_id}/tweets"

    bearer_token = Application.get_env(:geoffclayton_website, :six_music_twitter)[:bearer_token]

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
    tweet_text
    |> String.split("\n")
    |> Enum.at(line_num)
    |> String.replace(replace_str, "")
  end

  @topic "now_playing"

  def get_latest_track() do
    body_from_response = get_data_from_twitter()
    |> extract_body_from_twitter_response()

    # Need to do something to handle no interet connection here
    latest_tweet_text = body_from_response
    |> Map.get("data")
    |> List.first()
    |> Map.get("text")

    artist = extract_artist_from_tweet_text(latest_tweet_text)
    song = extract_song_from_tweet_text(latest_tweet_text)

    #Logger.debug(artist)
    #Logger.debug(song)

    current = %Track{artist: artist, song: song}

    if (! (current |> Track.equals(Track.last_inserted))) do
      GeoffclaytonWebsite.Repo.insert(current)

      GeoffclaytonWebsiteWeb.Endpoint.broadcast_from(self(), @topic, "new_track", %{last_ten: Track.last_ten})
    end

    current
  end
end
