defmodule Dryhard.Repo do
  use Ecto.Repo,
    otp_app: :dryhard,
    adapter: Ecto.Adapters.Postgres
end
