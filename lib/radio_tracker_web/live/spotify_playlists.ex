defmodule RadioTrackerWeb.SpotifyPlaylists do
  use RadioTrackerWeb, :live_view

  alias RadioTracker.Spotify.Playlist
  alias RadioTracker.Accounts

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
        IO.inspect(playlists)
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
end
