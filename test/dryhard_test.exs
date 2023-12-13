defmodule DryhardTest do
  use ExUnit.Case, async: true

  alias Dryhard.{Repo, User}
  import Dryhard.Factory

  @user %{username: "Bruce Lee", age: 2023 - 1940, bio: "Bruce Lee - the legend"}
  @user2 %{username: "Bruce Willis", age: 2023 - 1955, bio: "Dry Hard"}

  defmodule UserContext do
    # https://elixirforum.com/t/prototyping-and-enforcing-context-function-conventions/38821/2
    # trying https://gist.github.com/baldwindavid/7da385f0e79cbee62331d5be0b8c75db

    require Dryhard
    import Ecto.Query

    @resource Dryhard.config(User, Repo, "users")

    # Common CRUD functions
    Dryhard.list(@resource)
    Dryhard.get!(@resource)
    Dryhard.get(@resource)
    Dryhard.new(@resource)
    Dryhard.create(@resource, &User.changeset/2)
    Dryhard.upsert(@resource, &User.changeset/2)
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
    Dryhard.join(@resource, :company)
    Dryhard.filter_by_one(@resource, :company)
    # Dryhard.filter_by_one_or_many(@resource, :unit_type)
    Dryhard.order_by(@resource, :username, :desc)
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

  test "list_users works" do
    insert(:user, @user)
    insert(:user, @user2)
    UserContext.list_users()

    UserContext.list_users(fn query ->
      QueryBuilder.where(query, [], [username: "Bruce Lee"], or: [username: "Bruce Willis"])
    end)

    UserContext.list_users(fn query ->
      query
      |> UserContext.preload_user_company()
      |> UserContext.preload_user_posts()
    end)
  end

  test "get_user works" do
    insert(:user)
    insert(:user)
    [user1, _user2] = UserContext.list_users()
    assert user1 == UserContext.get_user(user1.id)
  end

  test "create_user works" do
    {:ok, user1} = UserContext.create_user(%{username: "user1"})
    assert user1 == UserContext.get_user_by_username("user1")
  end

  test "upsert_user works (ignore conflicts on inserts by default)" do
    {:ok, user1} = UserContext.upsert_user(%{username: "user1"})
    {:ok, _user1_duplicate} = UserContext.upsert_user(%{username: "user1"})
    assert user1 == UserContext.get_user_by_username("user1")
  end

  test "update_user works" do
    {:ok, user1} = UserContext.create_user(%{username: "user1"})
    assert user1 == UserContext.get_user_by_username("user1")
    {:ok, user1_changed} = UserContext.update_user(user1, %{bio: "CHANGED"})
    assert user1_changed.bio == "CHANGED"
    user1_new = UserContext.get_user_by_username("user1")
    assert user1_new.bio == "CHANGED"
  end

  test "delete_user works" do
    {:ok, user1} = UserContext.create_user(%{username: "user1"})
    assert user1 == UserContext.get_user_by_username("user1")
    {:ok, _user1_deleted} = UserContext.delete_user(user1)
    assert nil == UserContext.get_user_by_username("user1")
  end
end
