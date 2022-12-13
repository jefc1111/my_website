defmodule RadioTracker.Schemas.Like do
  use Ecto.Schema
  alias RadioTracker.Schemas.Play
  alias RadioTracker.Accounts.User

  schema "likes" do
    belongs_to :play, Play
    belongs_to :user, User

    timestamps()
  end
end
