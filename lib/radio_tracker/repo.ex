defmodule RadioTracker.Repo do
  use Ecto.Repo,
    otp_app: :radio_tracker,
    adapter: Ecto.Adapters.Postgres
end
