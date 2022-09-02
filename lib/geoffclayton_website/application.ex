defmodule GeoffclaytonWebsite.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      GeoffclaytonWebsite.Repo,
      # Start the Telemetry supervisor
      GeoffclaytonWebsiteWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: GeoffclaytonWebsite.PubSub},
      # Start the Endpoint (http/https)
      GeoffclaytonWebsiteWeb.Endpoint
      # Start a worker by calling: GeoffclaytonWebsite.Worker.start_link(arg)
      # {GeoffclaytonWebsite.Worker, arg}
    ]

    SixMusic.start_job()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GeoffclaytonWebsite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GeoffclaytonWebsiteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
