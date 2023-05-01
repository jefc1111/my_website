defmodule RadioTrackerWeb.LiveComponents.SpotifyLinks do
  use Phoenix.LiveComponent

  use Phoenix.HTML

  attr :show_warning, :boolean, default: false

  def render(assigns) do
    ~H"""
    <div>
      <%= if (@track.spotify_uri !== nil) do %>
        <%= link("App", to: {:spotify, String.replace(@track.spotify_uri, "spotify:", "")}) %>
        |
        <%=
          link("Web", to: String.replace(@track.spotify_uri, "spotify:track:", "https://open.spotify.com/track/"),
          target: "_blank")
        %>
        <%= if (assigns[:current_user]) do %>
        |
        Add to playlist
        <% end %>
      <% else %>
        <%= if (@show_warning) do %>
          Spotify URI could not be found
        <% end %>
      <% end %>
    </div>
    """
  end

  # def handle_event("delete-user-likes-for-track", data, socket) do
  #   Repo.get(Track, data["track-id"])
  #   |> Repo.preload([plays: :likes])
  #   |> Track.delete_all_likes_for_user(socket.assigns.user_id)

  #   send self(), {:list_change, data}

  #   {:noreply, socket}
  # end
end
