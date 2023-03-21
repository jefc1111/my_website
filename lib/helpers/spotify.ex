
defmodule RadioTracker.Helpers.Spotify do
  def is_fully_integrated?(user) do
    is_integrated_at_client_level?() && is_integrated_at_user_level?(user)
  end

  def is_integrated_at_client_level?() do
    Application.get_env(:radio_tracker, :spotify_api)[:client_id]
        && Application.get_env(:radio_tracker, :spotify_api)[:client_secret]
  end

  def is_integrated_at_user_level?(user) do
    user.spotify_linked_at !== nil
  end
end
