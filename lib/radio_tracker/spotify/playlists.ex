defmodule RadioTracker.Spotify.Playlists do
  use HTTPoison.Base

  alias RadioTracker.Spotify.Authorization

  def get_all(user) do
    {:ok, res_body} = Authorization.do_user_req(user, "https://api.spotify.com/v1/me/playlists")

    res_body["items"]
  end
end
