defmodule RadioTracker.Schemas.Play do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias RadioTracker.Repo
  alias RadioTracker.Schemas.Track
  alias RadioTracker.Schemas.Like

  schema "plays" do
    has_many :likes, Like

    belongs_to :track, Track

    timestamps()
  end

  @doc false
  def changeset(play, attrs) do
    play
    |> cast(attrs, [:track_id])
    |> validate_required([:track_id])
  end

  def last_inserted do
    __MODULE__
    |> Ecto.Query.last(:inserted_at)
    |> Repo.one
    |> Repo.preload([:track])
  end

  def last_ten do
    query =
      from p in __MODULE__,
      order_by: [desc: p.id],
      limit: 10,
      preload: [track: [plays: :likes]]

    Repo.all query
  end
end
