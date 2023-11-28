defmodule DryhardUserTest do
  use ExUnit.Case, async: true
  alias Dryhard.{Repo, User}

  defmodule UserContext do
    require Dryhard
    import Ecto.Query
    @resource Dryhard.config(User, Repo, "users")

    # Common CRUD functions
    Dryhard.list(@resource)
    Dryhard.get!(@resource)
    Dryhard.get(@resource)
    Dryhard.new(@resource)
    Dryhard.create(@resource, &User.changeset/2)
    Dryhard.change(@resource, &User.changeset/2)
    Dryhard.update(@resource, &User.changeset/2)
    Dryhard.delete(@resource)

    # CRUD helpers
    Dryhard.paginate(@resource)
    Dryhard.get_for!(@resource, :company)
    Dryhard.get_for(@resource, :company)
    Dryhard.get_by_attr!(@resource, :username)
    Dryhard.get_by_attr(@resource, :username)
    Dryhard.preload(@resource, :posts)
    Dryhard.preload(@resource, :company)
    Dryhard.preload(@resource, :likes)
    Dryhard.order_by(@resource, :username, :desc)
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

  require Dryhard.Testing

  @resource Dryhard.Testing.config(UserContext,
              schema: User,
              repo: Repo,
              plural: "users",
              factory: Dryhard.Factory
            )
  Dryhard.Testing.list(@resource)
  Dryhard.Testing.get(@resource)
  Dryhard.Testing.get!(@resource)
  Dryhard.Testing.create(@resource, %{username: "username1"})
  Dryhard.Testing.update(@resource, %{username: "changed"})
  Dryhard.Testing.delete(@resource)
  Dryhard.Testing.paginate(@resource)
end
