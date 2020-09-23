defmodule HelloSocketsWeb.StatsChannel do
  use Phoenix.Channel

  def join("valid", _payload, socket) do
    channel_join_increment("success")
    {:ok, socket}
  end

  def join("invalid", _payload, _socket) do
    channel_join_increment("fail")
    {:error, %{reason: "always fails"}}
  end

  @doc """
  The measure/2 function accepts a function that it will both execute and time.
  The time taken by the function will be reported to StatsD as a metric and the
  return value of the function is returned. This means we can measure different
  parts of our code very quickly by wrapping our code in the measure function.
  """
  def handle_in("ping", _payload, socket) do
    HelloSockets.Statix.measure("stats_channel.ping", fn ->
      Process.sleep(:rand.uniform(1000))
      {:reply, {:ok, %{ping: "pong"}}, socket}
    end)
  end

  def handle_in("slow_ping", _payload, socket) do
    Process.sleep(3_000)
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

  @doc """
  We can respond in a separate
  process that executes in parallel with our Channel, meaning we can process
  all messages concurrently. We’ll use Phoenix’s socket_ref/1 function to turn our
  Socket into a minimally represented format that can be passed around.

  We spawn a linked Task that starts a new process and executes the given
  function. The ref variable used by this function is a stripped-down version of
  the socket. We pass a reference to the Socket around, rather than the full thing,
  to avoid copying potentially large amounts of memory around the application.
  Task is used to get a Process up and running very quickly. In practice, however,
  you’ll probably be calling into a GenServer. You should always pass the socket_ref
  to any function you call.

  Finally, we use Phoenix.Channel.reply/2 to send a response to the Socket. This
  serializes the message into a reply and sends it to the Socket transport pro-
  cess. Once this occurs, our client receives the response as if it came directly
  from the Channel. The outside client has no idea that any of this occurred.

  p100
  """
  def handle_in("parallel_slow_ping", _payload, socket) do
    # https://hexdocs.pm/phoenix/Phoenix.Channel.html#reply/2
    ref = socket_ref(socket)

    Task.start_link(fn ->
      Process.sleep(3_000)
      Phoenix.Channel.reply(ref, {:ok, %{ping: "pong"}})
    end)

    {:noreply, socket}
  end

  defp channel_join_increment(status) do
    HelloSockets.Statix.increment("channel_join", 1,
      tags: ["status:#{status}", "channel:StatsChannel"]
    )
  end
end
