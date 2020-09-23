defmodule HelloSockets.Pipeline.Producer do
  use GenStage

  alias HelloSockets.Pipeline.Timing

  def start_link(opts) do
    {[name: name], opts} = Keyword.split(opts, [:name])
    GenStage.start_link(__MODULE__, opts, name: name)
  end

  def init(_opts) do
    {:producer, :unused, buffer_size: 10_000}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  def push(item = %{}) do
    GenStage.cast(__MODULE__, {:notify, item})
  end

  @doc """
  provides the current time with the items when it casts
  to the GenStage producer process. This is important because it’s possible for
  the notify message to be delayed if there are many items in the producer’s
  message queue. If we captured the current time in the handle_cast function,
  then our measurement won’t represent the entire pipeline.
  """
  def push_timed(item = %{}) do
    GenStage.cast(__MODULE__, {:notify_timed, item, Timing.unix_ms_now()})
  end

  def handle_cast({:notify_timed, item, unix_mx}, state) do
    {:noreply, [%{item: item, enqueued_at: unix_mx}], state}
  end

  def handle_cast({:notify, item}, state) do
    {:noreply, [%{item: item}], state}
  end
end
