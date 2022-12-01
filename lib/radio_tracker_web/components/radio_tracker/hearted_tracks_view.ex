defmodule RadioTrackerWeb.HeartedTracksView do
  use RadioTrackerWeb, :html

  alias RadioTracker.Helpers.Dates
  alias RadioTracker.Schemas.Track

  embed_templates "../templates/hearted_tracks/*"
end
