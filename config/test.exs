import Config

config :dryhard, Dryhard.Repo,
  database: "dryhard_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  poolsize: 10,
  pool: Ecto.Adapters.SQL.Sandbox,
  # in ms
  ownership_timeout: 12_000_000

config :logger, level: :warning
# config :logger, level: :debug
