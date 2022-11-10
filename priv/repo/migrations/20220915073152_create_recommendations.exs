defmodule RadioTracker.Repo.Migrations.CreateRecommendations do
  use Ecto.Migration

  def change do
    create table ("recommendations") do
      add :play_id, references (:plays)
      add :name, :text
      add :text, :text

      timestamps()
    end
  end
end
