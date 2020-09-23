use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hello_sockets, HelloSocketsWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# we should test that our pipeline emits a StatsD metric at the end of
# processing. We will use StatsDLogger in a special test mode to write this test–it
# will forward any stats to the test process rather than the StatsD server. Let’s
# configure our test environment for StatsD and then write our test.
config :statix, HelloSockets.Statix, port: 8127
