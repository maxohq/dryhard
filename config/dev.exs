import Config

config :dryhard, Dryhard.Repo,
  database: "dryhard_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  poolsize: 10
