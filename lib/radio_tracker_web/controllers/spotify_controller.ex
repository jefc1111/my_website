defmodule RadioTrackerWeb.SpotifyController do
  use RadioTrackerWeb, :controller

  use HTTPoison.Base

  def index(conn, _params) do
    state = random_string(16);
    scope = "playlist-modify-private playlist-modify-public";

    # Write state on the user object

    query_params = %{
      "response_type" => "code",
      "client_id" => Application.get_env(:radio_tracker, :spotify_api)[:client_id],
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
        url = "https://accounts.spotify.com/api/token"

        body = [
          {"code", code},
          {"redirect_uri", "http://localhost:4000/spotify-link-callback"},
          {"grant_type", "authorization_code"}
        ]

        client_id = Application.get_env(:radio_tracker, :spotify_api)[:client_id]
        client_secret = Application.get_env(:radio_tracker, :spotify_api)[:client_secret]

        encoded = Base.encode64("#{client_id}:#{client_secret}")

        headers = [
          {"Authorization", "Basic #{encoded}"}
        ]

        res = HTTPoison.post(url, {:form, body}, headers)
        IO.inspect(res)

        # Don't hard code this app's callback URLs
        # Put client id and secret and spotify URLs in config
        # Use Poison to decode the body etc
        # Store the main and refresh tokens
        # Go back to profile page showing "linked to Spotify" and directions or option to unlink
      %{"state" => _} ->
        IO.inspect("The state did not match")
      _ ->
        IO.inspect("Something very unexpected happened")
    end

    redirect(conn, to: ~p"/users/settings")
  end
end
