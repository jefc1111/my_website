defmodule RadioTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias RadioTracker.Poller

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      RadioTracker.Repo,
      # Start the Telemetry supervisor
      RadioTrackerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: RadioTracker.PubSub},
      # Start the Endpoint (http/https)
      RadioTrackerWeb.Endpoint
      # Start a worker by calling: RadioTracker.Worker.start_link(arg)
      # {RadioTracker.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RadioTracker.Supervisor]
    res = Supervisor.start_link(children, opts)

    Poller.start_job({Poller, :handle_poll, []})

    res
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RadioTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
