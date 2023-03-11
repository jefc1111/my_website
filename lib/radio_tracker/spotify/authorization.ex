defmodule RadioTracker.Spotify.Authorization do

  use HTTPoison.Base

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
    res_body = do_req({"grant_type", "client_credentials"})

    res_body["access_token"]
  end

  defp do_req(body) do
    url = "https://accounts.spotify.com/api/token"

    {:ok, res} = HTTPoison.post(url, {:form, body}, get_headers())

    {:ok, res_body} = Poison.decode(res.body)

    res_body
  end

  defp get_headers() do
    client_id = Application.get_env(:radio_tracker, :spotify_api)[:client_id]
    client_secret = Application.get_env(:radio_tracker, :spotify_api)[:client_secret]

    encoded = Base.encode64("#{client_id}:#{client_secret}")

    [{"Authorization", "Basic #{encoded}"}]
  end
end
