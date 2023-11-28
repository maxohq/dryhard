defmodule Dryhard.User do
  use Ecto.Schema
  use QueryBuilder
  import Ecto.Changeset

  schema "users" do
    field(:username, :string)
    field(:age, :integer)
    field(:password, :string)
    field(:bio, :string)

    belongs_to(:company, Dryhard.Company)
    has_many(:posts, Dryhard.Post)
    has_many(:likes, Dryhard.Like)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> base_changeset(attrs)
    |> cast_assoc(:posts, with: &Dryhard.Post.nested_changeset/2)
  end

  @doc false
  def create_changeset(user, attrs) do
    attrs = Map.put(attrs, :username, "create_changeset")
    base_changeset(user, attrs)
  end

  @doc false
  def update_changeset(user, attrs) do
    attrs = Map.put(attrs, :username, "update_changeset")
    base_changeset(user, attrs)
  end

  defp base_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :age, :password, :bio, :company_id])
    |> validate_required([:username])
    |> validate_length(:username, min: 2)
    |> validate_number(:age, greater_than: 0)
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/[0-9]+/, message: "must contain a number")
    |> validate_format(:password, ~r/[A-Z]+/, message: "must contain an upper-case letter")
    |> validate_format(:password, ~r/[a-z]+/, message: "must contain a lower-case letter")
  end
end
