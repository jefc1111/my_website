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
    |> assign(:allow_undo_track_ids, [])

    {:ok, socket}
  end

  def handle_info(%{event: "new_track"} = data, socket) do
    socket = socket
    |> assign(:last_ten, data.payload.last_ten)
    |> assign(:allow_undo_track_ids, data.payload.allow_undo_track_ids)

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

    Endpoint.broadcast(
      @topic,
      "new_track",
      %{
        last_ten: Track.last_ten,
        allow_undo_track_ids: [ track.id | socket.assigns.allow_undo_track_ids ]
      }
    )

    {:noreply, socket}
  end

  def handle_event("undo", data, socket) do
    track = Repo.get(Track, data["track-id"])
    |> Repo.preload([:recommendations])

    unless length(track.recommendations) === 0 do
        Repo.delete(List.last(track.recommendations))

        Endpoint.broadcast(
          @topic,
          "new_track",
          %{
            last_ten: Track.last_ten,
            allow_undo_track_ids: List.delete(socket.assigns.allow_undo_track_ids, track.id
          )}
        )
    end

    {:noreply, socket}
  end
end
