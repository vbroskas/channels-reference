defmodule HelloSocketsWeb.PingChannel do
  use Phoenix.Channel
  intercept ["request_ping"]

  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("param_ping", %{"error" => true}, socket) do
    {:reply, {:error, %{reason: "You asked for this!"}}, socket}
  end

  def handle_in("param_ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("pong", _payload, socket) do
    {:noreply, socket}
  end

  @doc """
  we must provide an exit reason and an optional response. We are pro-
  viding an :ok and map tuple as our response, but we can omit this argument for an equally correct response.
  """
  def handle_in("ding", _payload, socket) do
    {:stop, :shutdown, {:ok, %{msg: "shutting down"}}, socket}
  end

  def handle_in("ping:" <> phrase, _payload, socket) do
    {:reply, {:ok, %{ping: phrase}}, socket}
  end

  @doc """
  You’ll notice that the payload uses strings and not atoms. Atoms are not
  garbage collected by the BEAM, so Phoenix does not provide user-submitted
  data as atoms. You can use either atoms or string when creating a response
  payload.
  """
  def handle_in("ping", %{"ack_phrase" => ack_phrase}, socket) do
    {:reply, {:ok, %{ping: ack_phrase}}, socket}
  end

  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

  def handle_out("request_ping", payload, socket) do
    push(socket, "send_ping", Map.put(payload, "from_node", Node.self()))
    {:noreply, socket}
  end
end
