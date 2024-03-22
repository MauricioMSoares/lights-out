defmodule LightsOut.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    unless Mix.env == :prod do
      Dotenv.load
      Mix.Task.run("loadconfig")
    end

    children = [
      LightsOutWeb.Telemetry,
      {LightsOut.SoundServer, %{sfx: true, music: true}},
      {LightsOut.LanguageServer, %{locale: "en"}},
      {DNSCluster, query: Application.get_env(:lights_out, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LightsOut.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LightsOut.Finch},
      # Start a worker by calling: LightsOut.Worker.start_link(arg)
      # {LightsOut.Worker, arg},
      # Start to serve requests, typically the last entry
      LightsOutWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LightsOut.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LightsOutWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
