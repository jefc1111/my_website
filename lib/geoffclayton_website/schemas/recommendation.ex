defmodule GeoffclaytonWebsite.Schemas.Recommendation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recommendations" do
    field :name, :string
    field :text, :string

    belongs_to :track, GeoffclaytonWebsite.Schemas.Track

    timestamps()
  end

  def changeset(post, params \\ %{}) do
    post
    |> cast(params, [:name, :text])
    |> validate_required([:name, :text])
  end
end
