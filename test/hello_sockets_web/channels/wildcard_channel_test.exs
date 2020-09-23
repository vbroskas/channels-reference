defmodule HelloSocketsWeb.WildcardChannelTest do
  use HelloSocketsWeb.ChannelCase
  import ExUnit.CaptureLog
  alias HelloSocketsWeb.UserSocket

  '''
  The socket/3 function returns a Phoenix.Socket struct that would be created if the

  given handler, id, and assigned state were provided to our Socket implemen-
  tation. This is a useful convenience function allowing us to set up initial state

  without going through the process of connecting our real Socket.
  '''

  describe "join/3 success" do
    test "ok when numbers in the format a:b where b = 2a" do
      assert {:ok, _, %Phoenix.Socket{}} =
               socket(UserSocket, nil, %{})
               |> subscribe_and_join("wild:2:4", %{})

      assert {:ok, _, %Phoenix.Socket{}} =
               socket(UserSocket, nil, %{})
               |> subscribe_and_join("wild:100:200", %{})
    end
  end

  '''
  We use subscribe_and_join/3 to join the given topic with certain params. The correct
  Channel to use is inferred by matching the topic with the provided Socket
  implementation. This ensures that our Socket has the appropriate Channel
  routes defined, which adds to our test coverage.
  '''

  describe "join/3 error" do
    test "error when b is not exactly twice a" do
      assert socket(UserSocket, nil, %{})
             |> subscribe_and_join("wild:1:3", %{}) == {:error, %{}}
    end

    test "error when 3 numbers are provided" do
      assert socket(UserSocket, nil, %{})
             |> subscribe_and_join("wild:1:2:3", %{}) == {:error, %{}}
    end
  end

  describe "join/3 error causing crash" do
    test "error with an invalid format topic" do
      assert socket(UserSocket, nil, %{})
             |> subscribe_and_join("wild:12", %{}) == {:error, %{}}

      # assert capture_log(fn ->
      #          socket(UserSocket, nil, %{})
      #          |> subscribe_and_join("wild:12 ", %{})
      #        end) =~ "[error] an exception was raised"
    end
  end

  describe "handle_in ping" do
    test "a pong response is provided" do
      assert {:ok, _, socket} =
               socket(UserSocket, nil, %{})
               |> subscribe_and_join("wild:2:4", %{})

      ref = push(socket, "ping", %{})
      reply = %{ping: "pong"}
      assert_reply ref, :ok, ^reply
    end
  end
end
