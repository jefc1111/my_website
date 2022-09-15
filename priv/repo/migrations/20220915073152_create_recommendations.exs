defmodule GeoffclaytonWebsite.Repo.Migrations.CreateRecommendations do
  use Ecto.Migration

  def change do
    create table ("recommendations") do
      add :track_id, references (:tracks)
      add :name, :text
      add :text, :text

      timestamps()
    end
  end
end
