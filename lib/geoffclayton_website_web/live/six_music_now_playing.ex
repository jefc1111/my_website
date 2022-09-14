defmodule GeoffclaytonWebsiteWeb.SixMusicNowPlaying do
  require Logger

  use GeoffclaytonWebsiteWeb, :live_view

  alias GeoffclaytonWebsite.Track

  @topic "now_playing"

  def mount(_params, _session, socket) do
    GeoffclaytonWebsiteWeb.Endpoint.subscribe(@topic)

    socket = socket
    |> assign(:last_ten, Track.last_ten)
    |> assign(:status, "Getting new data...")

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
end
