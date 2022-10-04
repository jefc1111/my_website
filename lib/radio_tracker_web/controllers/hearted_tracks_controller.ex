defmodule RadioTrackerWeb.HeartedTracksController do
  use RadioTrackerWeb, :controller

  alias RadioTracker.Schemas.Track

  def index(conn, _params) do
    conn
    |> assign(:hearted_tracks, Track.hearted)
    |> render("index.html")
  end
end
