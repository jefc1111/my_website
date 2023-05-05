defmodule RadioTrackerWeb.LiveComponents.SpotifyLinks do
  use Phoenix.LiveComponent

  use Phoenix.HTML

  import RadioTrackerWeb.Components.Icon

  attr :show_warning, :boolean, default: false

  def render(assigns) do
    ~H"""
    <div>
      <%= if (@track.spotify_uri !== nil) do %>
        <div style="display: inline-block" title={"Source: #{spotify_uri_source_tooltip(@track.spotify_uri_source)}"}>
          <.icon
            name="spotify"
            type="brands"
            class={"icon spotify-playlist-link #{spotify_uri_source_class(@track.spotify_uri_source)}"}
          />
        </div>
        <%=
          link("App", to: {:spotify, String.replace(@track.spotify_uri, "spotify:", "")})
        %>
        <%=
          link("Web", to: String.replace(@track.spotify_uri, "spotify:track:", "https://open.spotify.com/track/"),
          target: "_blank")
        %>
        <%= if (assigns[:current_user]) do %>
          <button class="button is-success">
            <span class="icon is-small">
              <.icon
                name="plus"
                type="solid"
                class={"icon"}
              />
            </span>
          </button>
        <% end %>
      <% else %>
        <%= if (@show_warning) do %>
          Spotify URI could not be found
        <% end %>
      <% end %>
    </div>
    """
  end

  def spotify_uri_source_class(source) do
    case source do
      :spotify_api_filtered_search -> "uri-source-filtered"
      :spotify_api_general_search -> "uri-source-general"
      _ -> nil
    end
  end

  def spotify_uri_source_tooltip(source) do
    case source do
      :spotify_api_filtered_search -> "Spotify API search (filtered)"
      :spotify_api_general_search -> "Spotify API search (general)"
      _ -> "unknown"
    end
  end

  # def handle_event("delete-user-likes-for-track", data, socket) do
  #   Repo.get(Track, data["track-id"])
  #   |> Repo.preload([plays: :likes])
  #   |> Track.delete_all_likes_for_user(socket.assigns.user_id)

  #   send self(), {:list_change, data}

  #   {:noreply, socket}
  # end
end
