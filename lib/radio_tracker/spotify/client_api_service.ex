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
    result = do_api_query(
      track,
      state.access_token,
      "track:\"#{track.song}\" artist:\"#{track.artist}\"",
      :spotify_api_filtered_search
    )

    access_token = case result do
      {:ok, access_token} ->
        access_token
      {_, _} ->
        Logger.info("No result from filtered search, trying free text search.")

        # Now try free text based search
        # Doesn't really matter what happens here, we just want to pass on the
        # access token regardless
        {_, access_token} = do_api_query(
          track,
          state.access_token,
          "#{track.song} #{track.artist}",
          :spotify_api_general_search
        )

        access_token
    end



    {:noreply, Map.put(state, :access_token, access_token)}
  end

  defp do_api_query(track, access_token, search_query, spotify_uri_source) do
    query_params = %{
      "q" => search_query,
      "type" => "track",
      "market" => "GB",
      "limit" => 1
    }

    query_str = URI.encode_query(query_params)

    url = "https://api.spotify.com/v1/search?#{query_str}"

    [result: result, access_token: new_access_token] = Authorization.do_client_req(url, access_token)

    items = case result do
      {:ok, body} -> body["tracks"]["items"]
      _ -> Logger.info("Did not find any items in the Spotify search API response")
    end

    case items do
      [item] -> # We should only get one item because of limit = 1
        track
        |> Ecto.Changeset.change(
            %{
              spotify_uri: item |> Map.get("uri"),
              spotify_uri_source: spotify_uri_source
            }
          )
        |> Repo.update()

        Endpoint.broadcast_from(self(), @topic, "new_track", %{last_ten_plays: Play.last_ten})

        {:ok, new_access_token}
      [_|_] ->
        Logger.info("Received more than one result from Spotify search API.")

        {:too_many_result, new_access_token}
      [] ->
        Logger.info("No results from Spotify search API.")

        {:no_results, new_access_token}
      _ ->
        Logger.info("Something unexpected happened when using the Spotify search API.")

        {:error, new_access_token}
    end
  end
end
