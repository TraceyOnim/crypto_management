defmodule CryptoManagement.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Transaction.Cache,
      # Start the Ecto repository
      CryptoManagement.Repo,
      # Start the Telemetry supervisor
      CryptoManagementWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CryptoManagement.PubSub},
      # Start the Endpoint (http/https)
      CryptoManagementWeb.Endpoint,
      # Start a worker by calling: CryptoManagement.Worker.start_link(arg)
      # {CryptoManagement.Worker, arg}
      CryptoManagement.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CryptoManagement.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CryptoManagementWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
