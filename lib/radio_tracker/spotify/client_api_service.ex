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

    state = Map.put(state, :access_token, Authorization.get_client_credentials_access_token())

    {:ok, state}
  end

  @impl true
  def handle_cast({:new_track, track}, state) do
    # If we had to get a new access token (because there was none, or it had expired). Set new token on state.

    query_params = %{
      "q" => "track:\"#{track.song}\" artist:\"#{track.artist}\"",
      "type" => "track",
      "market" => "GB",
      "limit" => 1
    }

    headers = [
      {"Authorization", "Bearer #{state.access_token}"},
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]

    query_str = URI.encode_query(query_params)

    url = "https://api.spotify.com/v1/search?#{query_str}"
    IO.inspect(url)
    IO.inspect(state.access_token)
    {:ok, res} = HTTPoison.get(url, headers)
    IO.inspect(res)
    # Need to to proper handling here
    {:ok, body} = Poison.decode(res.body)

    items = body["tracks"]["items"]

    case items do
      [item] -> # We should only get one item because of limit = 1
        track
        |> Ecto.Changeset.change(%{spotify_uri: item |> Map.get("uri")})
        |> Repo.update()
        Endpoint.broadcast_from(self(), @topic, "new_track", %{last_ten_plays: Play.last_ten})
      _ ->
        Logger.info("No results from Spotify search API.")
        nil # The search did not reap any results so we're not going to do anything
    end

    # curl -X "GET" "https://api.spotify.com/v1/search?q=%2520track%3ADon't%20Bring%20Me%20Down%2520artist%3AGoldrush&type=track&market=GB&limit=5" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer BQBBCA2MJuO4sDIpWSWCOeFhF8_xf-LYS9hloiD6MY_BTpAKYr83jvFGPnVjJhDlgMH33_MT3LbQ54aqsMkFcoafA1FbRN-xnoOnv8WCUKxtfFpL3OKUfFSnqHGirINwHfkYR7Zphqz2hMzrpwOC017ETLco2jNLQCCwUy2L-0wC"

    # tracks.items[0].uri

    {:noreply, state}
  end

  @impl true
  def handle_call(:world, _from, state) do
    IO.inspect("CALL")
    {:reply, state, "D"}
  end
end
