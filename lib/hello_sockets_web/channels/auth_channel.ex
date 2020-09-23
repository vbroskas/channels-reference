defmodule HelloSocketsWeb.AuthChannel do
  use Phoenix.Channel
  require Logger
  alias HelloSockets.Pipeline.Timing

  intercept ["push_timed"]

  def join("user:" <> req_user_id, _payload, socket = %{assigns: %{user_id: user_id}}) do
    if req_user_id == to_string(user_id) do
      {:ok, socket}
    else
      Logger.error("#{__MODULE__} failed #{req_user_id} != #{user_id}")
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc """
  AuthChannel will intercept outgoing "push_timed" events now. Our handle_out callback
  will run, and it immediately pushes the data to the client. We capture the
  elapsed milliseconds by taking the difference between now and enqueued_at.
  We are using a histogram metric type to capture statistical information with
  our metric. Histograms aggregate several attributes of a given metric, such
  as percentiles, count, and sum. You will often use a histogram type when
  capturing a timing metric.
  """
  def handle_out("push_timed", %{data: data, at: enqueued_at}, socket) do
    push(socket, "push_timed", data)
    HelloSockets.Statix.histogram("pipeline.push_delivered", Timing.unix_ms_now() - enqueued_at)

    {:noreply, socket}
  end
end
