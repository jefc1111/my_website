defmodule GeoffclaytonWebsite.SixMusicTwitterPoller do
  alias GeoffclaytonWebsite.Schemas.Track
  alias GeoffclaytonWebsite.Repo
  alias GeoffclaytonWebsiteWeb.Endpoint

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

    # minimum max_results on the API is 5 (we only really need 1)
    url = "https://api.twitter.com/2/users/#{source_twitter_account_id}/tweets?max_results=5"

    bearer_token = Application.get_env(:geoffclayton_website, :six_music_twitter)[:bearer_token]

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

  @topic "now_playing"

  defguard is_in_second_minute(seconds_elapsed) when seconds_elapsed < 120
    and seconds_elapsed >= 60

  def handle_poll() do
    last_track_saved  = Track.last_inserted

    seconds_since_last_track = Timex.diff(DateTime.utc_now, last_track_saved.inserted_at, :seconds)

    case seconds_since_last_track do
      seconds_since_last_track when seconds_since_last_track < 60 ->
        {:noreply, "Not polling Twitter - track only started less than a minute ago"}
      seconds_since_last_track when is_in_second_minute(seconds_since_last_track)
        and rem(seconds_since_last_track, 10) === 0 -> poll_twitter(last_track_saved)
      _ -> poll_twitter(last_track_saved)
    end
  end

  defp poll_twitter(last_track_saved) do
    twitter_response = get_data_from_twitter()
    |> extract_body_from_twitter_response()

    case twitter_response do
      {:ok, twitter_response_body} ->
        current_track = extract_current_track(twitter_response_body)

        # Can I get rid of this `if`?
        if (! Track.equals(current_track, last_track_saved)) do
          handle_new_track(current_track)
        end
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

  defp handle_new_track(new_track) do
    Repo.insert(new_track)

    Endpoint.broadcast_from(self(), @topic, "new_track", %{last_ten: Track.last_ten})
  end
end
