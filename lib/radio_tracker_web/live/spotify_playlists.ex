defmodule RadioTrackerWeb.SpotifyPlaylists do
  use RadioTrackerWeb, :live_view

  alias RadioTracker.Spotify.Playlist
  alias RadioTracker.Accounts
  alias RadioTracker.Schemas.UserSpotifyPlaylist
  alias RadioTracker.Repo

  import RadioTrackerWeb.Components.Icon

  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    {:ok, socket |> assign(current_user: user)}
  end

  # If no user logged in, redirect
  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/")}
  end

  #@impl Phoenix.LiveView
  def handle_params(params, _, socket) do
    case Playlist.get_user_playlists(socket.assigns.current_user, params) do
      {:ok, {playlists, meta}} ->

        socket = socket
        |> assign(playlists: playlists)
        |> assign(meta: meta)
        |> assign(url_params: params) # idk, seems kinda shonky stuffing the url params on like this for use in handle_info

        {:noreply, socket}
      _ ->
        {:noreply, push_navigate(socket, to: "/")}
    end
  end

  def handle_info({:list_change, _data}, socket) do
    {:noreply,
     push_patch(socket,
       to: Routes.live_path(socket, __MODULE__, socket.assigns.url_params)
     )
    }
  end

  def handle_event("select-playlist", value, socket) do
    # {:ok, new_temp} = Thermostat.inc_temperature(socket.assigns.id)
    # {:noreply, assign(socket, :temperature, new_temp)}
    IO.inspect(socket)

    Repo.insert(%UserSpotifyPlaylist{
      user_id: socket.assigns.current_user.id,
      playlist_id: value["playlist-id"],
      playlist_name: value["playlist-name"]
    })

    {:noreply, socket}
  end
end
