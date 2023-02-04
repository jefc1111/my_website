defmodule RadioTracker.DataAcquisition.Twitter do
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Schemas.Play
  alias RadioTracker.Repo
  alias RadioTrackerWeb.Endpoint

  require Logger
  require Periodic
  require String
  @moduledoc """
  Documentation for `SixMusic`.
  """

  @topic "now_playing"

  defp get_data_from_twitter() do
    source_twitter_account_id = Application.get_env(:radio_tracker, :six_music_twitter)[:account_id]

    # minimum max_results on the API is 5 (we only really need 1)
    url = "https://api.twitter.com/2/users/#{source_twitter_account_id}/tweets?max_results=5"

    bearer_token = Application.get_env(:radio_tracker, :six_music_twitter)[:bearer_token]

    HTTPoison.get(url, ["Authorization": "Bearer #{bearer_token}"])
  end

  defp extract_body_from_twitter_response(response) do
    case response do
      {:ok, %{status_code: 200, body: body}} -> {:ok, Poison.decode!(body)}
      {:ok, %{status_code: 200}} -> {:error, "No body found"}
      {:ok, %{status_code: 404}} -> {:error, "It was a 404"}
      {:ok, %{status_code: 429}} -> {:error, "Rate limit exceeded - cannot get new data from Twitter"}
      {:error, %{reason: reason}} -> {:error, "Something bad happened: #{reason}"}
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

  def poll(last_play) do
    twitter_response = get_data_from_twitter()
    |> extract_body_from_twitter_response()

    case twitter_response do
      {:ok, twitter_response_body} ->
        # Note: the response bbdy does not include a timestamp for when the tweet was made.
        # I guess we would have to a separate reques for tweets of interest to get timestamps.
        now_playing_track = extract_current_track(twitter_response_body)

        unless (last_play != nil && Track.equals(now_playing_track, last_play.track)) do
          handle_new_track(now_playing_track)
        end
        # No alternative action required as we have established that the track has not changed yet
      {:error, msg} -> handle_bad_twitter_response(msg)
    end
  end

  defp handle_bad_twitter_response(msg) do
    Endpoint.broadcast_from(self(), @topic, "twitter_down", %{msg: msg})
  end

  defp extract_current_track(twitter_response_body) do
    # Need to do something to handle no interet connection here
    latest_tweet_text = twitter_response_body
    |> Map.get("data")
    |> List.first()
    |> Map.get("text")

    %Track{
      artist: extract_artist_from_tweet_text(latest_tweet_text),
      song: extract_song_from_tweet_text(latest_tweet_text)
    }
  end

  defp handle_new_track(now_playing_track) do
    res = Track.get_by_artist_song(now_playing_track.artist, now_playing_track.song)

    #IO.inspect(res)

    case res do
      nil -> Repo.insert(%Play{track: now_playing_track})
      existing_track = ^res -> Repo.insert(%Play{track_id: existing_track.id})
    end

    Endpoint.broadcast_from(self(), @topic, "new_track", %{last_ten_plays: Play.last_ten})
  end
end
