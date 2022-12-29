defmodule RadioTrackerWeb.HeartedTracks do
  use RadioTrackerWeb, :live_view


  alias RadioTracker.Helpers.Dates
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Repo
  alias RadioTracker.Accounts

  import RadioTrackerWeb.Components.Icon

  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    socket = socket
    |> assign(current_user: user)

    {:ok, socket}
  end

  # If no user logged in, redirect
  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/")}
  end

  #@impl Phoenix.LiveView
  def handle_params(params, _, socket) do
    case Track.list_liked(
      params,
      socket.assigns.current_user.id,
      %{
        start: "2020-12-08",
        end: "2023-12-10"
      }
    ) do
      {:ok, {tracks, meta}} ->
        socket = socket
        |> assign(tracks: tracks)
        |> assign(meta: meta)
        |> assign(url_params: params) # idk, seems kinda shonky stuffing the url params on like this for use in handle_info

        {:noreply, socket}
      _ ->
        {:noreply, push_navigate(socket, to: "/")}
    end
  end

  def handle_info({:list_change, _data}, socket) do
    {:noreply,
     push_redirect(socket,
       to: Routes.live_path(socket, __MODULE__, socket.assigns.url_params)
     )
    }
  end

  def handle_info({:date_range_change, data}, socket) do
    url_parms = Map.merge(
      socket.assigns.url_params,
      %{
        start: data["start"],
        end: data["end"]
      }
    )
    {:noreply,
     push_redirect(socket,
       to: Routes.live_path(socket, __MODULE__, url_parms)
     )
    }
  end
end
