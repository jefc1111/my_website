defmodule RadioTracker.Schemas.Track do
  @moduledoc "The Track module"

  require Logger

  use Ecto.Schema
  use Timex
  use Flop

  import Ecto.Query
  import Ecto.Changeset

  alias RadioTracker.Repo
  alias RadioTracker.Paginator
  alias RadioTracker.Schemas.Play
  alias RadioTracker.Schemas.Like

  @derive {
    Flop.Schema,
    filterable: [],
    sortable: [],
    default_limit: 10
  }

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

  # i.e. 2022-12-25
  defp convert_date(date_str) do
    components = date_str
    |> String.split("-")
    |> Enum.map(&Integer.parse(&1)
    |> elem(0))

    Date.new(
      Enum.at(components, 0),
      Enum.at(components, 1),
      Enum.at(components, 2)
    )
    |> elem(1)
  end

  def list_liked(params, user_id, %{start: start_date, end: end_date}) do
    # @todo: this is a bit duplicated with list_liked_scope/3
    count_query = from(
      from t in __MODULE__,
      distinct: t.id,
      inner_join: p in assoc(t, :plays),
      inner_join: r in assoc(p, :likes),
      on: r.play_id == p.id,
      where: fragment("date(st0.inserted_at) >= ?", ^convert_date(start_date)),
      where: fragment("date(st0.inserted_at) <= ?", ^convert_date(end_date)),
      where: fragment("sl2.user_id = ?", ^user_id)
    )

    list_liked_scope(user_id, start_date, end_date)
    |> Flop.validate_and_run(
      params,
      for: __MODULE__,
      count_query: count_query
    )
  end

  defp list_liked_scope(user_id, start_date, end_date) do
    from t in __MODULE__,
    inner_join: p in assoc(t, :plays),
    inner_join: r in assoc(p, :likes),
    on: r.play_id == p.id,
    select: t,
    order_by: [
      desc: count(r.id),
      desc: t.inserted_at
    ],
    group_by: t.id,
    preload: [plays: :likes],
    where: fragment("date(t0.inserted_at) >= ?", ^convert_date(start_date)),
    where: fragment("date(t0.inserted_at) <= ?", ^convert_date(end_date)),
    where: fragment("l2.user_id = ?", ^user_id)
  end
  #defp scope(q, %User{role: :admin}), do: q
  #defp scope(q, %User{id: user_id}), do: where(q, user_id: ^user_id)

  def list_all(params, %{start: start_date, end: end_date}) do
    count_query = from(
      from t in __MODULE__,
      distinct: t.id,
      inner_join: p in assoc(t, :plays),
      full_join: r in assoc(p, :likes),
      where: fragment("date(st0.inserted_at) >= ?", ^convert_date(start_date)),
      where: fragment("date(st0.inserted_at) <= ?", ^convert_date(end_date))
    )

    list_all_scope(start_date, end_date)
    |> Flop.validate_and_run(
      params,
      for: __MODULE__,
      count_query: count_query
    )
  end

  defp list_all_scope(start_date, end_date) do
    from t in __MODULE__,
    inner_join: p in assoc(t, :plays),
    full_join: r in assoc(p, :likes),
    select: t,
    order_by: [desc: count(p.id)],
    group_by: t.id,
    preload: [plays: :likes],
    where: fragment("date(t0.inserted_at) >= ?", ^convert_date(start_date)),
    where: fragment("date(t0.inserted_at) <= ?", ^convert_date(end_date))
  end

  def qty_likes(track) do
    track.plays
    |> Enum.map(fn p -> length(p.likes) end)
    |> Enum.sum
  end

  def qty_likes_for_user(track, user_id) do
    track.plays
    |> Enum.map(fn p -> length(Enum.filter(p.likes, fn l -> l.user_id == user_id end)) end)
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

  def delete_all_likes_for_user(track, user_id) do
    play_ids = Enum.map(track.plays, fn p -> p.id end)

    query =
      from l in Like,
      where: l.user_id == ^user_id,
      where: l.play_id in ^play_ids

    Repo.delete_all(query)
  end
end
