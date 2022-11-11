defmodule RadioTrackerWeb.TracksController do
  use RadioTrackerWeb, :controller

  alias RadioTracker.Schemas.Track
  alias RadioTracker.Repo

  def index(conn, params) do
    t = Repo.get(Track, params["id"])
    |> Repo.preload(plays: :recommendations)

    render(conn, "index.html", track: t, total_recs: Track.total_recs(t))
  end
end
