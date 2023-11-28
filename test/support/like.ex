defmodule Dryhard.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    belongs_to(:user, Dryhard.User)
    belongs_to(:post, Dryhard.Post)

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:post_id, :user_id])
    |> validate_required([:post_id, :user_id])
    |> foreign_key_constraint(:post_id)
    |> foreign_key_constraint(:user_id)
  end
end
