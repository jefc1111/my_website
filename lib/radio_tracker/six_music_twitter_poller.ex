defmodule RadioTracker.SixMusicTwitterPoller do
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Repo
  alias RadioTrackerWeb.Endpoint

  require Logger
  require Periodic
  require String
  @moduledoc """
  Documentation for `SixMusic`.
  """

  @topic "now_playing"

  # Twitter's 'elevated access' API limit is 2_000_000 tweets pulled per month.
  # It does not appear to be possible to pull fewer than 5 in one go.
  # This results in an average of pulling 5 tweets around every 7.5 seconds.
  # The dormant phase and slow poll phase mean it would probably be possible to poll more
  # frequently. But every 7.5 seconds is probably enough anyway.
  # Supporting other radio stations may impact how best to do this.
  @twitter_poll_interval_secs 8
  @slow_poll_phase_multiplier 2
  @dormant_secs_after_track_change 60
  @slow_poll_secs_after_dormant 30

  # The idea is, after the track changes, you go for some time (@dormant_secs_after_track_change) before starting to poll again,
  # then for some further period of time (@slow_poll_secs_after_dormant) you poll at a less regular interval which is defined
  # by @twitter_poll_interval_secs * @slow_poll_phase_multiplier (i.e. 5 * 2 = poll every 10 secconds during the 'slow poll phase')

  def start_job(run_spec) do
    Periodic.start_link(
      # https://elixirforum.com/t/crashes-in-periodic-after-a-code-reload/35865
      run: run_spec,
      # @todo: when a new track is detected, there's no need to be polling every 5 seconds straight away. Maybe wait 30 seconds, then poll
      # every 10 seconds, then at 60 seconds start going every 5 seconds again. Bit unnecessarily fancy I guess, but kinda cool.
      every: :timer.seconds(@twitter_poll_interval_secs)
    )
  end

  defp get_data_from_twitter() do
    IO.puts("Polling twitter")
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

  defguard is_in_slow_poll_phase?(seconds_elapsed)
    when seconds_elapsed < @dormant_secs_after_track_change + @slow_poll_secs_after_dormant
    and seconds_elapsed >= @dormant_secs_after_track_change

  def handle_poll() do
    qty_tracks = Repo.aggregate(Track, :count, :id)

    cond do
      qty_tracks === 0 -> poll_twitter(nil)
      true ->
        last_track_saved = Track.last_inserted

        seconds_since_last_track = Timex.diff(DateTime.utc_now, last_track_saved.inserted_at, :seconds)

        case seconds_since_last_track do
          seconds_since_last_track when seconds_since_last_track < @dormant_secs_after_track_change ->
            {:noreply, "Not polling Twitter - current track only started less than a minute ago"}
          seconds_since_last_track when is_in_slow_poll_phase?(seconds_since_last_track)
            and rem(seconds_since_last_track, @slow_poll_phase_multiplier * @twitter_poll_interval_secs) === 0 ->
               poll_twitter(last_track_saved)
          _ -> poll_twitter(last_track_saved)
        end
    end
  end

  defp poll_twitter(last_track_saved) do
    twitter_response = get_data_from_twitter()
    |> extract_body_from_twitter_response()

    case twitter_response do
      {:ok, twitter_response_body} ->
        # Note: the response bbdy does not include a timestamp for when the tweet was made.
        # I guess we would have to a separate reques for tweets of interest to get timestamps.
        current_track = extract_current_track(twitter_response_body)

        unless (Track.equals(current_track, last_track_saved)) do
          IO.puts("New track")
          handle_new_track(current_track)
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

  defp handle_new_track(new_track) do
    Repo.insert(new_track)

    Endpoint.broadcast_from(self(), @topic, "new_track", %{last_ten: Track.last_ten})
  end
end
