defmodule HelloSocketsWeb.DuplicateChannelTest do
  use HelloSocketsWeb.ChannelCase
  alias HelloSocketsWeb.UserSocket

  @doc """
  We use our helper functions to repeatedly broadcast messages to our Channel
  and then check its internal state. We ensure that no message has been sent
  to the client by using refute_push/2 with very loose pattern matching.
  """
  test "a buffer is maintained as numbers are broadcasted" do
    connect()
    |> broadcast_number(1)
    |> validate_buffer_contents([1])
    |> broadcast_number(1)
    |> validate_buffer_contents([1, 1])
    |> broadcast_number(2)
    |> validate_buffer_contents([2, 1, 1])

    refute_push _, _
  end

  @doc """
  test that our buffer drains correctly.

  We are using Process.sleep/1 in order to wait long enough for our Channel to
  have drained the buffer. This can cause the test suite to be slower, although
  there are slightly more complex alternatives. If you placed a configurable
  timeout for draining the buffer in the test suite, you would be able to sleep
  for much less time. Alternatively, you could develop a way to ask the Channel
  process how many times it has drained and then wait until it increases. The
  sleep function is great for this test because it keeps the code simple.

  assert_push/3 and refute_push/3 delegate to ExUnit’s assert_receive and refute_receive
  functions with a pattern that matches the expected Phoenix.Socket.Message. This
  means the Channel messages are located in our test process’s mailbox and
  can be inspected manually when necessary. We are providing a timeout of 0
  for these functions, as we have already waited enough time for the processing
  to have finished.
  """
  test "the buffer is drained 1 second after a number is first added" do
    connect()
    |> broadcast_number(1)
    |> broadcast_number(1)
    |> broadcast_number(2)

    Process.sleep(1050)
    assert_push "number", %{value: 1}, 0
    refute_push "number", %{value: 1}, 0
    assert_push "number", %{value: 2}, 0
  end

  @doc """
  push assertion functions are very useful when writing most tests, but
  they remove the ability to test that the messages are in a certain order. This
  matters for our Channel, so we will inspect the process mailbox manually.
  """
  test "the buffer drains with unique values in the correct order" do
    connect()
    |> broadcast_number(1)
    |> broadcast_number(2)
    |> broadcast_number(3)
    |> broadcast_number(2)

    Process.sleep(1050)

    assert {:messages,
            [
              %Phoenix.Socket.Message{
                event: "number",
                payload: %{value: 1}
              },
              %Phoenix.Socket.Message{
                event: "number",
                payload: %{value: 2}
              },
              %Phoenix.Socket.Message{
                event: "number",
                payload: %{value: 3}
              }
            ]} = Process.info(self(), :messages)
  end

  @doc """
  Our helper function accepts socket as the first parameter and returns it as the
  lone return value. This will allow us to use a pipeline operator to chain
  together our helper functions.any()

  All our helper functions are returning the socket reference. This pattern allows
  us to use pipeline function invocation.
  """
  defp broadcast_number(socket, number) do
    assert broadcast_from!(socket, "number", %{number: number}) == :ok
    socket
  end

  @doc """
  We use :sys.get_state/1 to retrieve the contents of our Channel.Server process that
  is created by the test helper. This creates a tight coupling between the process
  being spied on and the calling process, so you should limit its usage. It can
  be valuable when used sparingly in tests because it gives all the information
  about a process.
  """
  defp validate_buffer_contents(socket, expected_contents) do
    assert :sys.get_state(socket.channel_pid).assigns == %{
             awaiting_buffer?: true,
             buffer: expected_contents
           }

    socket
  end

  @doc """
  helper function to create the Socket. extract the Channel connection into a
  helper
  """
  defp connect() do
    assert {:ok, _, socket} =
             socket(UserSocket, nil, %{})
             |> subscribe_and_join("dupe", %{})

    socket
  end
end
