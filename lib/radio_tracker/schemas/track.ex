defmodule RadioTracker.Schemas.Track do
  @moduledoc "The Track module"

  require Logger

  use Ecto.Schema
  use Timex

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

  #def inserted_at_human_readable(track), do: "#{track.inserted_at.hour}:#{track.inserted_at.minute}:#{track.inserted_at.second}"

  def inserted_at_human_readable(track) do
    # Must be a nbetter way!
    secs_to_shift = Timex.Timezone.total_offset(Timex.Timezone.local)

    timex_res = track.inserted_at
    |> Timex.shift(seconds: secs_to_shift)
    |> Timex.format("{h24}:{m}:{s} {D}/{M}")

    case timex_res do
      {:ok, dt} -> dt
      _ -> "Not recognised"
    end
  end


  def last_ten do
    query =
      from t in __MODULE__,
      order_by: [desc: t.id],
      limit: 10,
      preload: [:recommendations]

    Repo.all query

    # "#{track.inserted_at.hour}:#{track.inserted_at.minute}:#{track.inserted_at.second}"
  end

  def hearted do
    query =
      from t in __MODULE__,
      left_join: r in assoc(t, :recommendations),
      #where: t.inserted_at == ^ Timex.today,
      where: not is_nil(r.id),
      order_by: [desc: count(r.id)],
      group_by: t.id,
      select: t,
      preload: [:recommendations]

    Repo.all query
  end
end
