defmodule HelloSocketsWeb.DuplicateChannel do
  use Phoenix.Channel

  intercept ["number"]

  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  @doc """
  receive new numbers from helper function
  """
  def handle_out("number", %{number: number}, socket) do
    buffer = Map.get(socket.assigns, :buffer, [])
    new_buffer = [number | buffer]

    updated_socket =
      socket
      |> assign(:buffer, new_buffer)
      |> enqueue_send_buffer()

    {:noreply, updated_socket}
  end

  @doc """
  push number to client
  """
  def handle_info(:send_buffer, socket = %{assigns: %{buffer: buffer}}) do
    # IO.puts("about to push buffer:")
    # IO.inspect(buffer)

    buffer
    |> Enum.reverse()
    |> Enum.uniq()
    |> Enum.each(&push(socket, "number", %{value: &1}))

    next_socket =
      socket
      # reset :buffer in assigns to empty list []
      |> assign(:buffer, [])
      # reset :awaiting_buffer? to false
      |> assign(:awaiting_buffer?, false)

    {:noreply, next_socket}
  end

  def broadcast(numbers, times) do
    Enum.each(1..times, fn _time ->
      Enum.each(numbers, fn number ->
        HelloSocketsWeb.Endpoint.broadcast!("dupe", "number", %{number: number})
        # IO.puts("number is: #{number}")
      end)
    end)
  end

  defp enqueue_send_buffer(socket = %{assigns: %{awaiting_buffer?: true}}) do
    # IO.puts("RUSHING")
    # IO.inspect(socket.assigns.buffer)
    socket
  end

  @doc """
  on first number in list sent, begin the countdown timer to send all numbers to client,
  continue processing incoming number in the meantime
  """
  defp enqueue_send_buffer(socket) do
    # IO.puts("Ready")
    # IO.inspect(socket.assigns.buffer)
    Process.send_after(self(), :send_buffer, 1000)
    assign(socket, :awaiting_buffer?, true)
  end
end
