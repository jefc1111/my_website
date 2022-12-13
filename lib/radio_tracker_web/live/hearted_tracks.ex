defmodule RadioTrackerWeb.HeartedTracks do
  use RadioTrackerWeb, :live_view

  alias RadioTracker.Helpers.Dates
  alias RadioTracker.Schemas.Track

  def mount(params, _session, socket) do

    socket = socket
    |> assign(hearted_tracks: Track.hearted(params))

    {:ok, socket}
  end
end
