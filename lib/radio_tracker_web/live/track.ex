defmodule RadioTrackerWeb.Track do
  use RadioTrackerWeb, :live_view

  alias RadioTracker.Repo
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Accounts
  alias RadioTracker.Helpers.Dates

  import RadioTrackerWeb.Components.Icon

  def mount(params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    t = Repo.get(Track, params["id"])
    |> Repo.preload(plays: :likes)

    socket = socket
    |> assign(current_user: user)
    |> assign(track: t)
    |> assign(qty_likes: Track.qty_likes(t))

    {:ok, socket}
  end

  # If no user logged in, redirect
  def mount(params, _session, socket) do
    t = Repo.get(Track, params["id"])
    |> Repo.preload(plays: :likes)

    socket = socket
    |> assign(track: t)
    |> assign(qty_likes: Track.qty_likes(t))

    {:ok, socket}
  end
end
