defmodule RadioTracker.Repo.Migrations.CreateSpotifyPlaylists do
  use Ecto.Migration

  def change do
    create table(:spotify_playlists) do
      add :user_id, references (:users)
      add :playlist_id, :text
      add :playlist_name, :text

      timestamps()
    end
  end
end
