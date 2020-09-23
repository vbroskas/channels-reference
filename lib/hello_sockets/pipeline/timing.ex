defmodule HelloSockets.Pipeline.Timing do
  @doc """
  get time when an item is added to our pipeline
  We’ll use this at the entry and exit points of our data pipeline.
  """
  def unix_ms_now() do
    :erlang.system_time(:millisecond)
  end
end
