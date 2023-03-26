defmodule RadioTracker.Repo.Migrations.AddSpotifyStuffToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :spotify_state, :text
      add :spotify_access_token, :text
      add :spotify_refresh_token, :text
      add :spotify_linked_at, :utc_datetime
    end
  end
end
