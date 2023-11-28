defmodule DryhardCommentTest do
  use ExUnit.Case, async: true
  alias Dryhard.{Repo, Comment}

  defmodule CommentsContext do
    require Dryhard
    import Ecto.Query
    @resource Dryhard.config(Comment, Repo, "comments")

    # Common CRUD functions
    Dryhard.list(@resource)
    Dryhard.get!(@resource)
    Dryhard.get(@resource)
    Dryhard.new(@resource)
    Dryhard.create(@resource, &Comment.changeset/2)
    Dryhard.change(@resource, &Comment.changeset/2)
    Dryhard.update(@resource, &Comment.changeset/2)
    Dryhard.delete(@resource)

    # CRUD helpers
    Dryhard.paginate(@resource)
    Dryhard.get_by_attr!(@resource, :content)
    Dryhard.get_by_attr(@resource, :content)
    Dryhard.preload(@resource, :posts)
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

  require Dryhard.Testing

  @resource Dryhard.Testing.config(CommentsContext,
              schema: Comment,
              repo: Repo,
              plural: "comments",
              factory: Dryhard.Factory
            )
  Dryhard.Testing.list(@resource)
  Dryhard.Testing.get(@resource)
  Dryhard.Testing.get!(@resource)

  Dryhard.Testing.create(@resource, %{content: "Content"}, fn config ->
    p = config.factory.insert(:post)
    %{post_id: p.id}
  end)

  Dryhard.Testing.update(@resource, %{content: "Content"}, fn config ->
    p = config.factory.insert(:post)
    %{post_id: p.id}
  end)

  Dryhard.Testing.delete(@resource)
  Dryhard.Testing.paginate(@resource)
end
