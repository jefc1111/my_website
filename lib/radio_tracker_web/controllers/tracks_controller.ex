defmodule RadioTrackerWeb.TracksController do
  use RadioTrackerWeb, :controller

  alias RadioTracker.Schemas.Track
  alias RadioTracker.Repo

  def get(conn, params) do
    t = Repo.get(Track, params["id"])
    |> Repo.preload(plays: :likes)

    render(conn, "track.html", track: t, qty_likes: Track.qty_likes(t))
  end

  def index(conn, params) do
    render(conn, "index.html", tracks: Track.all_paged(params))
  end
end
