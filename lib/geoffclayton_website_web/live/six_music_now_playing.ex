defmodule GeoffclaytonWebsiteWeb.SixMusicNowPlaying do
  require Logger

  use GeoffclaytonWebsiteWeb, :live_view

  alias GeoffclaytonWebsite.Track

  @topic "now_playing"

  def mount(_params, _session, socket) do
    GeoffclaytonWebsiteWeb.Endpoint.subscribe(@topic)

    socket = assign(socket, :last_ten, Track.last_ten)
    {:ok, socket}
  end

  def handle_info(data, socket) do
    socket = assign(socket, :last_ten, data.payload.last_ten)
    {:noreply, socket}
  end
end
