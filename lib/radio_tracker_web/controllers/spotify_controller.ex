defmodule RadioTrackerWeb.SpotifyController do
  use RadioTrackerWeb, :controller
  use HTTPoison.Base
  alias RadioTracker.Repo

  def index(conn, _params) do
    state = random_string(16);
    scope = "playlist-modify-private playlist-modify-public";

    conn.assigns.current_user
      |> Ecto.Changeset.change(%{spotify_state: state})
      |> Repo.update()

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
    IO.inspect(conn.assigns.current_user.spotify_state)


    case params do
      %{"code" => code, "state" => state} when state === conn.assigns.current_user.spotify_state ->
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

        {:ok, res} = HTTPoison.post(url, {:form, body}, headers)
        IO.inspect(res)

        {:ok, body} = Poison.decode(res.body)

        conn.assigns.current_user
          |> Ecto.Changeset.change(
            %{
              spotify_linked_at: DateTime.utc_now |> DateTime.truncate(:second),
              spotify_access_token: body["access_token"],
              spotify_refresh_token: body["refresh_token"]
            }
          )
          |> Repo.update()
      %{"state" => _} ->
        IO.inspect("The state did not match")
      _ ->
        IO.inspect("Something very unexpected happened")
    end

    redirect(conn, to: ~p"/users/settings")
  end

  def remove_link(conn, _params) do
    conn.assigns.current_user
      |> Ecto.Changeset.change(
        %{
          spotify_linked_at: nil,
          spotify_access_token: nil,
          spotify_refresh_token: nil
        }
      )
      |> Repo.update()

    redirect(conn, to: ~p"/users/settings")
  end
end
