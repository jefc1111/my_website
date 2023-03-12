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
  def handle_cast(:world, state) do
    IO.inspect("CAST")
    {:noreply, state}
  end


  @impl true
  def handle_cast({:push, head}, tail) do
    {:noreply, [head | tail]}
  end

  @impl true
  def handle_call(:world, _from, state) do
    IO.inspect("CALL")
    {:reply, state, "D"}
  end

end
