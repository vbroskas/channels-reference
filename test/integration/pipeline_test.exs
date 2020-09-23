defmodule Integration.PipelineTest do
  use HelloSocketsWeb.ChannelCase, async: false
  alias HelloSocketsWeb.AuthSocket
  alias HelloSockets.Pipeline.Producer

  @doc """
  We use our Producer module to enqueue an event that will eventually make its
  way to the Channel as an outgoing message. Everything behaves exactly the
  same as it did in our Channel tests that didn’t use the pipeline. We have to
  use a synchronous test, denoted by async: false, because our data pipeline is
  globally available to the test suite. Using a synchronous test prevents random
  test failures.
  We should always include a negative test to go with our positive test.
  """
  test "event are pushed from begining to end correctly" do
    connect_auth_socket(1)

    Enum.each(1..10, fn n ->
      Producer.push_timed(%{data: %{n: n}, user_id: 1})
      assert_push "push_timed", %{n: ^n}
    end)
  end

  test "an event is not delivered to the wrong user" do
    connect_auth_socket(2)
    Producer.push_timed(%{data: %{test: true}, user_id: 1})
    refute_push "push_timed", %{test: true}
  end

  test "events are timed on delivery" do
    assert {:ok, _} = StatsDLogger.start_link(port: 8127, formatter: :send)
    connect_auth_socket(1)
    Producer.push_timed(%{data: %{test: true}, user_id: 1})
    assert_push "push_timed", %{test: true}
    assert_receive {:statsd_recv, "pipeline.push_delivered", _value}
  end

  defp connect_auth_socket(user_id) do
    {:ok, _, %Phoenix.Socket{}} =
      socket(AuthSocket, nil, %{user_id: user_id})
      |> subscribe_and_join("user:#{user_id}", %{})
  end
end
