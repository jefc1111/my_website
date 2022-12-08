defmodule RadioTracker.Repo.Migrations.RelateRecommendationToUser do
  use Ecto.Migration

  def change do
    alter table(:recommendations) do
      add :recommender_id, references(:users)
      add :recommendee_id, references(:users)
    end
  end
end
