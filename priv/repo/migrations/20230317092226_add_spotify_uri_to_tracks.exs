defmodule RadioTracker.Repo.Migrations.AddSpotifyUriToTracks do
  use Ecto.Migration

  def change do
    alter table(:tracks) do
      add :spotify_uri, :text
    end
  end
end
