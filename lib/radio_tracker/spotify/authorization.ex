defmodule RadioTracker.Spotify.Authorization do

  use HTTPoison.Base
  alias RadioTracker.Repo

  require Logger

  def get_authorization_code_tokens(code) do
    body = [
      {"code", code},
      {"redirect_uri", "#{RadioTrackerWeb.Endpoint.url()}/spotify-link-callback"},
      {"grant_type", "authorization_code"}
    ]

    res_body = do_token_acquisition_req(body)

    %{
      access_token: res_body["access_token"],
      refresh_token: res_body["refresh_token"]
    }
  end

  # Get a token to be used for accessing the public (non-scoped) API
  def get_client_credentials_access_token() do
    res_body = do_token_acquisition_req([{"grant_type", "client_credentials"}])

    res_body["access_token"]
  end

  defp do_token_acquisition_req(body) do
    url = "https://accounts.spotify.com/api/token"

    client_id = Application.get_env(:radio_tracker, :spotify_api)[:client_id]
    client_secret = Application.get_env(:radio_tracker, :spotify_api)[:client_secret]

    encoded = Base.encode64("#{client_id}:#{client_secret}")

    headers = [{"Authorization", "Basic #{encoded}"}]

    {:ok, res} = HTTPoison.post(
      url,
      {:form, body},
      headers
    )

    {:ok, res_body} = Poison.decode(res.body)

    res_body
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

    res_body = do_token_acquisition_req(body)

    user
    |> Ecto.Changeset.change(%{spotify_access_token: res_body["access_token"]})
    |> Repo.update()
  end

  # For requests relating to user-specific resources
  def do_user_req(user, url) do
    response = HTTPoison.get(url, get_authorization_code_headers(user))

    case response do
      {:ok, %{status_code: 200, body: body}} -> Poison.decode(body)
      {:ok, %{status_code: 401}} ->
        Logger.info("User's access token has expired - refreshing it now")

        refresh_user_access_token(user)

        response_from_retry = HTTPoison.get(url, get_authorization_code_headers(user))
IO.inspect(response_from_retry)
        case response_from_retry do
          {:ok, %{status_code: 200, body: body}} -> Poison.decode(body)
          {:ok, %{status_code: status_code}} -> Logger.error(status_code)
          _ -> Logger.error("Even after trying to refresh the access code it still seems like it didn't work.")
        end
      {:ok, %{status_code: 200}} -> Logger.error("no body found")
      {:ok, %{status_code: 404}} -> Logger.error("It was a 404")
      {:error, %{reason: reason}} -> Logger.error("Something bad happened: #{reason}")
    end
  end

  defp client_req_headers(access_token) do
    [
      {"Authorization", "Bearer #{access_token}"},
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]
  end

  # For requets to the public API (non-scoped)
  def do_client_req(url, access_token) do
    response = HTTPoison.get(url, client_req_headers(access_token))

    case response do
      {:ok, %{status_code: 200, body: body}} -> [result: Poison.decode(body), access_token: access_token]
      {:ok, %{status_code: 401}} ->
        Logger.info("The client access token has expired - getting a new one")

        new_access_token = get_client_credentials_access_token()

        response_from_retry = HTTPoison.get(url, client_req_headers(new_access_token))

        case response_from_retry do
          {:ok, %{status_code: 200, body: body}} -> [result: Poison.decode(body), access_token: new_access_token]
          _ -> Logger.error("Got a new token but it still did not work :(")
        end
      {:ok, %{status_code: 200}} -> Logger.error("no body found")
      {:ok, %{status_code: 404}} -> Logger.error("It was a 404")
      {:error, %{reason: reason}} -> Logger.error("Something bad happened: #{reason}")
    end
  end
end
