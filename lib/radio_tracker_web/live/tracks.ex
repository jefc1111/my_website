defmodule RadioTrackerWeb.Tracks do
  use RadioTrackerWeb, :live_view

  alias RadioTracker.Helpers.Dates
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Accounts

  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    socket = socket
    |> assign(current_user: user)
    |> assign(date_range: %{
      start: "2022-12-01",
      end: "2022-12-31"
    })

    {:ok, socket}
  end

  # If no user logged in, redirect
  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/")}
  end

  #@impl Phoenix.LiveView
  def handle_params(params, _, socket) do
    case Track.list_all(
      params,
      socket.assigns.date_range
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
end
