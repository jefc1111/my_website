defmodule RadioTracker.Spotify.ClientApiService do
  use GenServer

  alias RadioTracker.Repo
  alias RadioTracker.Spotify.Authorization
  alias RadioTrackerWeb.Endpoint
  alias RadioTracker.Schemas.Play

  require Logger

  @topic "now_playing"

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  ## Callbacks

  @impl true
  def init(state) do
    # When the app starts we'll get a fresh token.
    state = Map.put(state, :access_token, Authorization.get_client_credentials_access_token())

    {:ok, state}
  end

  @impl true
  def handle_cast({:new_track, track}, state) do
    query_params = %{
      "q" => "track:\"#{track.song}\" artist:\"#{track.artist}\"",
      "type" => "track",
      "market" => "GB",
      "limit" => 1
    }

    query_str = URI.encode_query(query_params)

    url = "https://api.spotify.com/v1/search?#{query_str}"

    [result: result, access_token: access_token] = Authorization.do_client_req(url, state.access_token)

    items = case result do
      {:ok, body} -> body["tracks"]["items"]
      _ -> Logger.info("Did not find any items in the Spotify search API response")
    end

    case items do
      [item] -> # We should only get one item because of limit = 1
        track
        |> Ecto.Changeset.change(%{spotify_uri: item |> Map.get("uri")})
        |> Repo.update()

        Endpoint.broadcast_from(self(), @topic, "new_track", %{last_ten_plays: Play.last_ten})
      [_|_] ->
        Logger.info("Received more than one result from Spotifly search API.")
      [] ->
        Logger.info("No results from Spotify search API.")
      _ ->
        Logger.info("Something unexpected happened when using the Spotify search API.")
    end

    {:noreply, Map.put(state, :access_token, access_token)}
  end

  @impl true
  def handle_call(:world, _from, state) do
    IO.inspect("CALL")
    {:reply, state, "D"}
  end
end
