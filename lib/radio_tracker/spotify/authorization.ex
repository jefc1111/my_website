defmodule RadioTracker.Spotify.Authorization do

  use HTTPoison.Base

  alias RadioTracker.Repo

  require Logger

  def get_authorization_code_tokens(code) do
    body = [
      {"code", code},
      {"redirect_uri", "http://localhost:4000/spotify-link-callback"},
      {"grant_type", "authorization_code"}
    ]

    res_body = do_req(body)

    %{
      access_token: res_body["access_token"],
      refresh_token: res_body["refresh_token"]
    }
  end

  def get_client_credentials_access_token() do
    res_body = do_req([{"grant_type", "client_credentials"}])

    res_body["access_token"]
  end

  defp do_req(body) do
    url = "https://accounts.spotify.com/api/token"

    {:ok, res} = HTTPoison.post(url, {:form, body}, get_client_credentials_headers())

    {:ok, res_body} = Poison.decode(res.body)

    res_body
  end

  defp get_client_credentials_headers() do
    client_id = Application.get_env(:radio_tracker, :spotify_api)[:client_id]
    client_secret = Application.get_env(:radio_tracker, :spotify_api)[:client_secret]

    encoded = Base.encode64("#{client_id}:#{client_secret}")

    [{"Authorization", "Basic #{encoded}"}]
  end

  defp get_authorization_code_headers(user) do
    [
      {"Authorization", "Bearer #{user.spotify_access_token}"},
      {"Content-Type", "application/json"}
    ]
  end

  defp refresh_user_access_token(user) do
    body = [
      {"refresh_token", user.spotify_refresh_token},
      {"grant_type", "refresh_token"}
    ]

    res_body = do_req(body)

    user
    |> Ecto.Changeset.change(%{spotify_access_token: res_body["access_token"]})
    |> Repo.update()
  end

  def do_user_req(user, url) do
    response = HTTPoison.get(url, get_authorization_code_headers(user))

    case response do
      {:ok, %{status_code: 200, body: body}} -> Poison.decode(body)
      {:ok, %{status_code: 401}} ->
        Logger.info("User's access token has expired - refreshing it now")

        refresh_user_access_token(user)

        response_from_retry = HTTPoison.get(url, get_authorization_code_headers(user))

        case response_from_retry do
          {:ok, %{status_code: 200, body: body}} -> Poison.decode(body)
          _ -> Logger.error("This is really bad. Even after trying to refresh the access code it still seems like it didn't work.")
        end
      {:ok, %{status_code: 200}} -> Logger.error("no body found")
      {:ok, %{status_code: 404}} -> Logger.error("It was a 404")
      {:error, %{reason: reason}} -> Logger.error("Something bad happened: #{reason}")
    end
  end
end
