defmodule RadioTracker.Spotify.Playlists do
  use HTTPoison.Base

  alias RadioTracker.Spotify.Authorization

  def get_all(user) do
    {:ok, result} = Authorization.do_user_req(user, "https://api.spotify.com/v1/me/playlists")

    result["items"]
  end
end
