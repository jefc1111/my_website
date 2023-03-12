defmodule RadioTracker.Spotify.ApiService do
  use GenServer

  def start_link(data) do
    GenServer.start_link(__MODULE__, data, name: __MODULE__)
  end

  ## Callbacks

  @impl true
  def init(stack) do
    IO.inspect("INIT")
    {:ok, stack}
  end

  @impl true
  def handle_cast({:new_track, track_id}, state) do
    IO.inspect("CAST")
    IO.inspect(track_id)
    # Get Track from DB
    # Use Spotify search API to get URI
    # Save URI to the DB
    # If we had ot get a new access token (because there was none, or it had expired). Set new token on state.

    {:noreply, state}
  end

  @impl true
  def handle_call(:world, _from, state) do
    IO.inspect("CALL")
    {:reply, state, "D"}
  end
end
