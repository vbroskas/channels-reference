defmodule HelloSockets.Pipeline.ConsumerSupervisor do
  @moduledoc """
  This ConsumerSupervisor module is, fittingly, a mix of common Supervisor and Con-
  sumer process setup. We configure our module to subscribe to the correct

  producer stage like we did for the regular Consumer. The biggest difference here
  is that we define what the children of our ConsumerSupervisor are.

  """
  use ConsumerSupervisor

  alias HelloSockets.Pipeline.{Producer, Worker}

  def start_link(opts) do
    ConsumerSupervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    subscribe_to = Keyword.get(opts, :subscribe_to, Producer)
    supervisor_opts = [strategy: :one_for_one, subscribe_to: subscribe_to]

    children = [
      %{id: Worker, start: {Worker, :start_link, []}, restart: :transient}
    ]

    ConsumerSupervisor.init(children, supervisor_opts)
  end
end
