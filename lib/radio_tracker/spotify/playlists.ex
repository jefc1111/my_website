defmodule RadioTracker.Spotify.Playlists do
  use HTTPoison.Base

  alias RadioTracker.Spotify.Authorization

  def get_all(user) do
    url = "https://api.spotify.com/v1/me/playlists"

    {:ok, res} = HTTPoison.get(url, Authorization.get_authorization_code_headers(user))

    {:ok, res_body} = Poison.decode(res.body)

    res_body["items"]
  end
end
