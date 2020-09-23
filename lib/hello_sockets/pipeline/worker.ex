defmodule HelloSockets.Pipeline.Worker do
  @doc """
  We are using Task.start_link/1 to start a new Process that runs our item-handler
  code. This simplifies our Worker because we don’t have to worry about setting
  up a new GenServer.
  """
  def start_link(item) do
    Task.start_link(fn ->
      HelloSockets.Statix.measure("pipeline.worker.process_time", fn ->
        process(item)
      end)
    end)
  end

  defp process(%{item: %{data: data, user_id: user_id}, enqueued_at: unix_ms} = input) do
    IO.inspect(input)
    Process.sleep(1000)

    HelloSocketsWeb.Endpoint.broadcast!("user:#{user_id}", "push_timed", %{
      data: data,
      at: unix_ms
    })
  end
end
