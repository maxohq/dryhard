defmodule Dryhard.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field(:title, :string)
    belongs_to(:user, Dryhard.User)
    has_many(:likes, Dryhard.Like)
    has_one(:comment, Dryhard.Comment)

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
    |> foreign_key_constraint(:user_id)
  end

  @doc false
  def nested_changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title])
    |> foreign_key_constraint(:user_id)
  end

  def nested_likes_changeset(post, attrs) do
    post
    |> changeset(attrs)
    |> cast_assoc(:likes, with: &Dryhard.Like.changeset/2)
  end

  def nested_comment_changeset(post, attrs) do
    post
    |> changeset(attrs)
    |> cast_assoc(:comment, with: &Dryhard.Comment.changeset/2)
  end
end
