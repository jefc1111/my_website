defmodule RadioTracker.Schemas.UserSpotifyPlaylist do
  use Ecto.Schema

  alias RadioTracker.Accounts.User

  schema "spotify_playlists" do
    belongs_to :user, User
    field :playlist_id, :string
    field :playlist_name, :string

    timestamps()
  end
end
