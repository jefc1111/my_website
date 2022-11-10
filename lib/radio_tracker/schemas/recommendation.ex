defmodule RadioTracker.Schemas.Recommendation do
  use Ecto.Schema
  import Ecto.Changeset
  alias RadioTracker.Schemas.Play

  schema "recommendations" do
    field :name, :string
    field :text, :string

    belongs_to :play, Play

    timestamps()
  end

  def changeset(post, params \\ %{}) do
    post
    |> cast(params, [:name, :text])
    |> validate_required([:name, :text])
  end
end
