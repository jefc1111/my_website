defmodule RadioTrackerWeb.Home do
  require Logger

  use RadioTrackerWeb, :live_view
  use Timex

  alias RadioTracker.Accounts
  alias RadioTracker.Repo
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Schemas.Like
  alias RadioTracker.Schemas.Play
  alias RadioTrackerWeb.Endpoint

  import RadioTrackerWeb.Components.Icon

  @topic "now_playing"

  def mount(_params, session, socket) do
    Endpoint.subscribe(@topic)

    socket = socket
    |> assign(:last_ten_plays, Play.last_ten)
    |> assign(:status, "Getting new data...")
    |> assign(:allow_undo_track_ids, [])

    case session do
      %{"user_token" => user_token} ->
        user = Accounts.get_user_by_session_token(user_token)

        {:ok, socket
        |> assign(:current_user, user)
        |> assign(:like_disabled, false)}
      _ ->
        {:ok, socket
        |> assign(:like_disabled, true)}
    end
  end

  def handle_info(%{event: "new_track", payload: %{allow_undo_track_ids: allow_undo_track_ids}} = data, socket) do
    socket = socket
    |> assign(:last_ten_plays, data.payload.last_ten_plays)
    |> assign(:allow_undo_track_ids, allow_undo_track_ids)

    {:noreply, socket}
  end

  def handle_info(%{event: "new_track"} = data, socket) do
    socket = socket
    |> assign(:last_ten_plays, data.payload.last_ten_plays)

    {:noreply, socket}
  end

  def handle_info(%{event: "twitter_down"} = data, socket) do
    socket = assign(socket, :status, data.payload.msg)

    {:noreply, socket}
  end

  def handle_info(_, socket) do
    socket = assign(socket, :status, "Something weird and unexpected happened")

    {:noreply, socket}
  end

  def handle_event("like", data, socket) do
    play = Repo.get(Play, data["play-id"])
    |> Repo.preload([:track])

    Repo.insert(
      %Like{
        play: play,
        user: socket.assigns.current_user
      }
    )

    Endpoint.broadcast(
      @topic,
      "new_track",
      %{
        last_ten_plays: Play.last_ten,
        allow_undo_track_ids: [ play.track.id | socket.assigns.allow_undo_track_ids ]
      }
    )

    {:noreply, socket}
  end

  def handle_event("undo", data, socket) do
    play = Repo.get(Play, data["play-id"])
    |> Repo.preload([:likes, :track])

    unless length(play.likes) === 0 do
        Repo.delete(List.last(play.likes))

        Endpoint.broadcast(
          @topic,
          "new_track",
          %{
            last_ten_plays: Play.last_ten,
            allow_undo_track_ids: List.delete(socket.assigns.allow_undo_track_ids, play.track.id
          )}
        )
    end

    {:noreply, socket}
  end
end
