defmodule RadioTrackerWeb.SixMusicNowPlaying do
  require Logger

  use RadioTrackerWeb, :live_view
  use Timex

  alias RadioTracker.Repo
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Schemas.Recommendation
  alias RadioTrackerWeb.Endpoint

  @topic "now_playing"

  def mount(_params, _session, socket) do
    Endpoint.subscribe(@topic)

    socket = socket
    |> assign(:last_ten, Track.last_ten)
    |> assign(:status, "Getting new data...")

    {:ok, socket}
  end

  def handle_info(%{event: "new_track"} = data, socket) do
    socket = assign(socket, :last_ten, data.payload.last_ten)
    {:noreply, socket}
  end

  def handle_info(%{event: "twitter_down"} = data, socket) do
    socket = assign(socket, :status, data.payload.msg)
    {:noreply, socket}
  end

  def handle_info(_, socket) do
    socket = assign(socket, :status, "Something weird and unexpected happened")
    {:noreply, socket}
  end

  def handle_event("like", data, socket) do
    track = Repo.get(Track, data["track-id"])

    Repo.insert(%Recommendation{name: "me", text: "stuff", track: track})

    Endpoint.broadcast(@topic, "new_track", %{last_ten: Track.last_ten})

    {:noreply, socket}
  end

  def handle_event("undo", data, socket) do
    track = Repo.get(Track, data["track-id"])
    |> Repo.preload([:recommendations])

    unless length(track.recommendations) === 0 do
        Repo.delete(List.last(track.recommendations))

        Endpoint.broadcast(@topic, "new_track", %{last_ten: Track.last_ten})
    end

    {:noreply, socket}
  end
end
