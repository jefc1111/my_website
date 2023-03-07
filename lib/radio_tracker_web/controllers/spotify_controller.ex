defmodule RadioTrackerWeb.SpotifyController do
  use RadioTrackerWeb, :controller

  use HTTPoison.Base

  def index(conn, _params) do
    state = random_string(16);
    scope = "playlist-modify-private playlist-modify-public";

    # Write state on the user object

    query_params = %{
      "response_type" => "code",
      "client_id" => "f76ee05f7ce74d0cb5720962bae8b2d1",
      "scope" => scope,
      "redirect_uri" => "http://localhost:4000/spotify-link-callback",
      "state" => state
    }

    query_str = URI.encode_query(query_params)

    redirect(conn, external: "https://accounts.spotify.com/authorize?#{query_str}")
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  def callback(conn, params) do
    IO.inspect(params)

    case params do
      %{"code" => code, "state" => state} -> # Match on state being same as state on the user object
        IO.inspect("DDD")
        url = "https://accounts.spotify.com/api/token"

        body = [
          {"code", code},
          {"redirect_uri", "http://localhost:4000/spotify-link-callback"},
          {"grant_type", "authorization_code"}
        ]

        encoded = Base.encode64("f76ee05f7ce74d0cb5720962bae8b2d1:SECRET")

        headers = [
          {"Authorization", "Basic #{encoded}"}
        ]

        res = HTTPoison.post(url, {:form, body}, headers)
        IO.inspect(res)

        # Use Poison to decode the body etc
        # Store the main and refresh tokens
        # Go back to profile page showing "linked to Spotify" and directions or option to unlink
      %{"code" => code, "state" => _} ->
        IO.inspect("EEE")
      _ ->
        IO.inspect("Something unexpected happened")
    end

    redirect(conn, to: ~p"/users/settings")
  end
end
