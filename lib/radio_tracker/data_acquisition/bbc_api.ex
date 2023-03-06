defmodule RadioTracker.DataAcquisition.BbcApi do
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
    url = "https://rms.api.bbc.co.uk/v2/services/bbc_6music/tracks/latest/playable"

    HTTPoison.get(url)
  end

  def poll(last_play) do
    full_response = get_data()

    case full_response do
      {:ok, api_response} ->
        now_playing_track = extract_current_track(api_response)

        unless (last_play != nil && Track.equals(now_playing_track, last_play.track)) do
          handle_new_track(now_playing_track)
        end
        # No alternative action required as we have established that the track has not changed yet
      {:error, msg} -> handle_bad_response(msg)
    end
  end

  defp extract_current_track(api_response) do
    latest_track_titles = Poison.decode!(api_response.body)
    |> Map.get("data")
    |> List.first()
    |> Map.get("titles")

    %Track{
      artist: Map.get(latest_track_titles, "secondary"),
      song: Map.get(latest_track_titles, "primary")
    }
  end

  defp handle_new_track(now_playing_track) do
    res = Track.get_by_artist_song(now_playing_track.artist, now_playing_track.song)

    case res do
      nil -> Repo.insert(%Play{track: now_playing_track})
      existing_track = ^res -> Repo.insert(%Play{track_id: existing_track.id})
    end

    Endpoint.broadcast_from(self(), @topic, "new_track", %{last_ten_plays: Play.last_ten})
  end

  defp handle_bad_response(msg) do
    Endpoint.broadcast_from(self(), @topic, "api_down", %{msg: msg})
  end
end
