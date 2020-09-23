defmodule HelloSocketsWeb.AuthSocket do
  use Phoenix.Socket
  require Logger

  channel "ping", HelloSocketsWeb.PingChannel
  channel "tracked", HelloSocketsWeb.TrackedChannel
  channel "user:*", HelloSocketsWeb.AuthChannel
  channel "recurring", HelloSocketsWeb.RecurringChannel

  @one_day 86400

  def connect(%{"token" => token}, socket) do
    case verify(socket, token) do
      {:ok, user_id} ->
        socket = assign(socket, :user_id, user_id)
        {:ok, socket}

      {:error, err} ->
        Logger.error("#{__MODULE__} connect error #{inspect(err)}")
        :error
    end
  end

  def connect(_, _socket) do
    Logger.error("#{__MODULE__} connect error missing params")
    :error
  end

  @doc """
  returns an idendifier for the socket. this is optional, but it is a best practice to identify a
  Socket when it’s for a particular user. We can do things like disconnecting a
  specific user or use the Socket identifier in other parts of the system.
  """
  def id(%{assigns: %{user_id: user_id}}) do
    "auth_socket:#{user_id}"
  end

  @doc """
  verify(context, salt, token, opts \\ [])

  "salt identifier can be anything as long as it remains the same between the token being signed and
  verified. You can generate a random string and either write it directly into
  your code or through a Mix.Config value. You can use the same salt for all
  users—it acts like a namespace for the token and is not a per-user salt.
  """
  defp verify(socket, token) do
    Phoenix.Token.verify(
      socket,
      "salt identifier",
      token,
      max_age: @one_day
    )
  end
end
