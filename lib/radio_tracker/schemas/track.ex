defmodule RadioTracker.Schemas.Track do
  @moduledoc "The Track module"

  require Logger

  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  alias RadioTracker.Repo

  schema "tracks" do
    field :artist, :string
    field :song, :string

    has_many :recommendations, RadioTracker.Schemas.Recommendation

    timestamps()
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:artist, :song])
    |> validate_required([:artist, :song])
  end

  def equals(%__MODULE__{artist: a1, song: t1}, %__MODULE__{artist: a2, song: t2}) do
    a1 === a2 && t1 === t2
  end

  def as_summary(%__MODULE__{artist: a, song: s}), do: "#{a} - #{s}"

  def last_inserted do
    __MODULE__
    |> Ecto.Query.last(:inserted_at)
    |> Repo.one
  end

  def last_ten do
    query = from p in __MODULE__,
      order_by: [desc: p.id],
      limit: 10

    query
    |> Repo.all
    |> Repo.preload([:recommendations])

    # "#{track.inserted_at.hour}:#{track.inserted_at.minute}:#{track.inserted_at.second}"
  end
end
