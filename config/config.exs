import Config

config :dryhard, ecto_repos: [Dryhard.Repo]
import_config "#{Mix.env()}.exs"
