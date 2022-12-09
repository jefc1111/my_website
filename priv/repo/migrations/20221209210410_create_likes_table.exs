defmodule RadioTracker.Repo.Migrations.CreateLikesTable do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :play_id, references (:plays)
      add :user_id, references (:users)

      timestamps()
    end
  end
end
