defmodule RadioTrackerWeb.HeartedTracks do
  use RadioTrackerWeb, :live_view

  alias RadioTracker.Repo
  alias RadioTracker.Helpers.Dates
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Accounts

  import RadioTrackerWeb.Components.Icon

  def mount(params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    socket = socket
    |> assign(current_user: user)
    |> assign(hearted_tracks: Track.hearted(
      params,
      user.id,
      %{
        start: "2020-12-08",
        end: "2023-12-10"
      }
    ))

    {:ok, socket}
  end

  # If no user logged in, redirect
  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/")}
  end

  def handle_event("delete-user-likes-for-track", data, socket) do
    Repo.get(Track, data["track-id"])
    |> Repo.preload([plays: :likes])
    |> Track.delete_all_likes_for_user(socket.assigns.current_user.id)

    socket = socket
    |> assign(hearted_tracks: Track.hearted(
      socket.assigns,
      socket.assigns.current_user.id,
      %{
        start: "2020-12-08",
        end: "2023-12-10"
      }
    ))

    {:noreply, socket}
  end

  def handle_event("set-date-range", data, socket) do
    IO.inspect(data)

    socket = socket
    |> assign(hearted_tracks: Track.hearted(
      socket.assigns,
      socket.assigns.current_user.id,
      %{
        start: data["start"],
        end: data["end"]
      }
    ))

    {:noreply, socket}
  end
end
