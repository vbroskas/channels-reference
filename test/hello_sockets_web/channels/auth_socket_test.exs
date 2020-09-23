defmodule HelloSocketsWeb.AuthSocketTest do
  use HelloSocketsWeb.ChannelCase

  # import of CaptureLog provides the capture_log/1 function, which will test that our code is properly logging output.
  import ExUnit.CaptureLog
  alias HelloSocketsWeb.AuthSocket

  describe "connect/3 succes" do
    test "can be connected to with valid token" do
      assert {:ok, %Phoenix.Socket{}} = connect(AuthSocket, %{"token" => generate_token(1)})
      assert {:ok, %Phoenix.Socket{}} = connect(AuthSocket, %{"token" => generate_token(2)})
    end
  end

  describe "connect/3 error" do
    # test "cannot be connected to with invalid salt" do
    #   params = %{"token" => generate_token(1, salt: "invalid")}

    #   assert capture_log(fn ->
    #            assert :error = connect(AuthSocket, params)
    #          end) =~ "[error] #{AuthSocket} connect error: invalid"
    # end

    test "cannot be connected to without token" do
      params = %{}

      assert capture_log(fn ->
               assert :error = connect(AuthSocket, params)
             end) =~ "[error] #{AuthSocket} connect error missing params"
    end

    # test "cannot be connected to with bad token" do
    #   params = %{"token" => "nonsense"}

    #   assert capture_log(fn ->
    #            assert :error = connect(AuthSocket, params)
    #          end) =~ "[error] #{AuthSocket} connect error: invalid"
    # end
  end

  describe "id/1" do
    test "an identifier is based on the connected ID" do
      assert {:ok, socket} = connect(AuthSocket, %{"token" => generate_token(1)})
      assert AuthSocket.id(socket) == "auth_socket:1"
      assert {:ok, socket} = connect(AuthSocket, %{"token" => generate_token(2)})
      assert AuthSocket.id(socket) == "auth_socket:2"

      IO.inspect(socket)
    end
  end

  defp generate_token(id, opts \\ []) do
    # get(keywords, key, default \\ nil)
    salt = Keyword.get(opts, :salt, "salt identifier")
    IO.puts("SALT IS: #{salt}")
    Phoenix.Token.sign(HelloSocketsWeb.Endpoint, salt, id)
  end
end
