defmodule GeoffclaytonWebsiteWeb.SixMusicNowPlaying do
  require Logger

  use GeoffclaytonWebsiteWeb, :live_view

  alias GeoffclaytonWebsite.Repo
  alias GeoffclaytonWebsite.Schemas.Track
  alias GeoffclaytonWebsite.Schemas.Recommendation
  alias GeoffclaytonWebsiteWeb.Endpoint

  @topic "now_playing"

  def mount(_params, _session, socket) do
    Endpoint.subscribe(@topic)

    socket = socket
    |> assign(:last_ten, Track.last_ten)
    |> assign(:status, "Getting new data...")
    |> assign(:test, "off")

    {:ok, socket}
  end

  def handle_info(%{event: "last_ten"} = data, socket) do
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

    Endpoint.broadcast(@topic, "last_ten", %{last_ten: Track.last_ten})

    {:noreply, socket}
  end

end
