defmodule RadioTracker.Repo.Migrations.AddSpotifyUriSourceToTracks do
  use Ecto.Migration

  def change do
    alter table(:tracks) do
      add :spotify_uri_source, :string
    end
  end
end
