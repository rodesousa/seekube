defmodule Seekube.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Supervisor

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SeekubeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Seekube.PubSub},
      # Start the Endpoint (http/https)
      SeekubeWeb.Endpoint,
      worker(
        Mongo,
        [[
          name: :mongo,
          url: System.get_env("MONGO_URL"),
          ssl: true,
          ssl_opts: [ciphers: ['AES256-GCM-SHA384'], versions: [:"tlsv1.2"]]
        ]]
      )
      # Start a worker by calling: Seekube.Worker.start_link(arg)
      # {Seekube.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Seekube.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SeekubeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
