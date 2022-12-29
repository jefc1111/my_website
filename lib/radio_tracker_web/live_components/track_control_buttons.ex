defmodule RadioTrackerWeb.LiveComponents.TrackControlButtons do
  use Phoenix.LiveComponent

  import RadioTrackerWeb.Components.Icon

  alias RadioTracker.Schemas.Track
  alias RadioTracker.Repo

  def render(assigns) do
    ~H"""
    <div x-data="{ open: false }" style="width: 124px">
      <button class="button is-small" x-on:click="open = ! open" x-show="! open">
          <.icon name="trash-can" type="regular" class="icon" />
      </button>
      <div class="buttons are-small" x-show="open">
        <button class="button is-success"
          phx-click="delete-user-likes-for-track"
          phx-target={@myself}
          phx-value-track-id={@track.id}
          x-on:click="open = ! open"
        >
            Sure?
        </button>
        <button class="button is-warning" x-on:click="open = ! open">
            x
        </button>
      </div>
    </div>
    """
  end

  def handle_event("delete-user-likes-for-track", data, socket) do
    Repo.get(Track, data["track-id"])
    |> Repo.preload([plays: :likes])
    |> Track.delete_all_likes_for_user(socket.assigns.user_id)

    send self(), {:list_change, data}

    {:noreply, socket}
  end
end
