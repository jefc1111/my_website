defmodule RadioTrackerWeb.HeartedTracks do
  use RadioTrackerWeb, :live_view

  alias RadioTracker.Repo
  alias RadioTracker.Helpers.Dates
  alias RadioTracker.Schemas.Track

  import RadioTrackerWeb.Components.Icon

  def mount(params, _session, socket) do

    socket = socket
    |> assign(hearted_tracks: Track.hearted(params))

    {:ok, socket}
  end

  def handle_event("delete-all-likes-for-track", data, socket) do
    Repo.get(Track, data["track-id"])
    |> Repo.preload([plays: :likes])
    |> Track.delete_all_likes()

    socket = socket
    |> assign(hearted_tracks: Track.hearted(socket.assigns))

    {:noreply, socket}
  end
end
