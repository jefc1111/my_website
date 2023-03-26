defmodule RadioTracker.DataAcquisition.RadioApi do
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

  defp get_data() do
    url = Application.get_env(:radio_tracker, :radio_api)[:now_playing_url]

    HTTPoison.get(url)
  end

  def poll(last_play) do
    full_response = get_data()

    case full_response do
      {:ok, api_response} ->
        # The track that is playing out right now
        now_playing_track = extract_current_track(api_response)

        # `last_play` is only likely to be nil if the database is empty of tracks
        # If the track hasn't changed since the last recorded play then do nothing
        unless (now_playing_track == nil ||
          (last_play != nil && Track.equals(now_playing_track, last_play.track))
        ) do
          handle_track_change(now_playing_track)
        end
        # No alternative action required as we have established that the track has not changed yet
      {:error, msg} -> handle_bad_response(msg)
    end
  end

  defp extract_current_track(api_response) do
    api_response_data = api_response.body

    case api_response_data do
      nil ->
        Logger.warn("Did not receive any actionable data from the radio API")
        nil
      body ->
        latest_track_titles = Poison.decode!(body)
        |> Map.get("data")
        |> List.first()
        |> Map.get("titles")

        %Track{
          artist: Map.get(latest_track_titles, "secondary"),
          song: Map.get(latest_track_titles, "primary")
        }
    end
  end

  defp handle_track_change(now_playing_track) do
    # Let's see if the track now playing has ever been played before
    res = Track.get_by_artist_song(now_playing_track.artist, now_playing_track.song)

    case res do
      # We haven't had this track before so we record a new play alongside a new track
      nil -> handle_previously_unseen_track(now_playing_track)
      # We've already seen this track so we record a new play for the exitsing track id
      existing_track = ^res -> Repo.insert(%Play{track_id: existing_track.id})
    end

    Endpoint.broadcast_from(self(), @topic, "new_track", %{last_ten_plays: Play.last_ten})
  end

  defp handle_previously_unseen_track(now_playing_track) do
    {:ok, play} = Repo.insert(%Play{track: now_playing_track})

    GenServer.cast(RadioTracker.Spotify.ClientApiService, {:new_track, play.track})
  end

  defp handle_bad_response(msg) do
    Endpoint.broadcast_from(self(), @topic, "api_down", %{msg: msg})
  end
end
