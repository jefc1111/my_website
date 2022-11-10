defmodule RadioTracker.Schemas.Play do
  use Ecto.Schema
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Schemas.Recommendation

  schema "plays" do
    has_many :recommendations, Recommendation

    belongs_to :track, Track

    timestamps()
  end
end
