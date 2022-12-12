defmodule RadioTracker.Schemas.Track do
  @moduledoc "The Track module"

  require Logger

  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias RadioTracker.Repo
  alias RadioTracker.Paginator
  alias RadioTracker.Schemas.Play

  schema "tracks" do
    field :artist, :string
    field :song, :string

    has_many :plays, Play

    timestamps()
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:artist, :song])
    |> validate_required([:artist, :song])
  end

  def equals(%__MODULE__{artist: a1, song: s1}, %__MODULE__{artist: a2, song: s2}) do
    a1 === a2 && s1 === s2
  end

  def equals(%__MODULE__{}, _), do: false

  def as_summary(%__MODULE__{artist: a, song: s}), do: "#{a} - #{s}"

  def last_inserted do
    __MODULE__
    |> Ecto.Query.last(:inserted_at)
    |> Repo.one
  end

  def hearted(params) do
    query =
      from t in __MODULE__,
      inner_join: p in assoc(t, :plays),
      inner_join: r in assoc(p, :recommendations),
      on: r.play_id == p.id,
      select: t,
      order_by: [desc: count(r.id)],
      group_by: t.id,
      preload: [plays: :recommendations],
      where: fragment("date(t0.inserted_at) >= ?", ^~D[2020-11-24]),
      where: fragment("date(t0.inserted_at) <= ?", ^~D[2022-11-26])
    Paginator.paginate(query, params["page"])
  end

  def all_paged(params) do
    query =
      from t in __MODULE__,
      inner_join: p in assoc(t, :plays),
      select: t,
      order_by: [desc: count(p.id)],
      group_by: t.id,
      preload: [:plays]
    Paginator.paginate(query, params["page"])
  end

  def total_recs(track) do
    track.plays
    |> Enum.map(fn p -> length(p.recommendations) end)
    |> Enum.sum
  end

  # It shouldn't really be necessary to do the LIMIT 1 because we should
  # only ever have one record in `tracks` for a given artist / song combination
  # Could enforce this at the DB level with a combined index I imagine ....
  def get_by_artist_song(artist, song) do
    query =
      from t in __MODULE__,
      where: t.artist == ^artist,
      where: t.song == ^song,
      order_by: [desc: t.inserted_at],
      limit: 1

    Repo.one(query)
  end
end
