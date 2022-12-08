defmodule RadioTracker.Schemas.Recommendation do
  use Ecto.Schema
  import Ecto.Changeset
  alias RadioTracker.Schemas.Play
  alias RadioTracker.Accounts.User

  schema "recommendations" do
    field :name, :string
    field :text, :string

    belongs_to :play, Play
    belongs_to :recommender, User
    belongs_to :recommendee, User

    timestamps()
  end

  def changeset(post, params \\ %{}) do
    post
    |> cast(params, [:name, :text, :play_id])
    |> validate_required([:name, :text, :play_id])
  end
end
