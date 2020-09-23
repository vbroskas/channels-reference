defmodule HelloSockets.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias HelloSockets.Pipeline.Producer
  alias HelloSockets.Pipeline.ConsumerSupervisor, as: Consumer

  def start(_type, _args) do
    :ok = HelloSockets.Statix.connect()

    children = [
      # Start the Telemetry supervisor
      HelloSocketsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HelloSockets.PubSub},
      {Producer, name: Producer},

      # You should tune
      # the max_demand to the maximum amount of processes that you want to run in
      # parallel, based on your use case.
      {Consumer, subscribe_to: [{Producer, max_demand: 10, min_demand: 5}]},
      # Start the Endpoint (http/https)
      HelloSocketsWeb.Endpoint
      # Start a worker by calling: HelloSockets.Worker.start_link(arg)
      # {HelloSockets.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloSockets.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HelloSocketsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
