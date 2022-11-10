defmodule RadioTracker.Repo.Migrations.CreatePlays do
  use Ecto.Migration

  def change do
    create table(:plays) do
      add :track_id, references (:tracks)

      timestamps()
    end

  end
end
