defmodule RadioTracker.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add :artist, :string
      add :song, :string

      timestamps()
    end

  end
end
