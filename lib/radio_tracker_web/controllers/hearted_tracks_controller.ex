defmodule RadioTrackerWeb.HeartedTracksController do
  use RadioTrackerWeb, :controller

  alias RadioTracker.Schemas.Track

  def index(conn, params) do
    render(conn, "index.html", hearted_tracks: Track.hearted)
  end
end
