defmodule DryhardIntrospectionTest do
  @moduledoc """
  - https://elixircasts.io/introspecting-ecto-schemas
  - https://hexdocs.pm/ecto/Ecto.Schema.html#module-reflection
  """
  use ExUnit.Case, async: true

  alias Dryhard.User

  describe "ecto" do
    test "basic info" do
      fields = User.__schema__(:fields)

      assert fields == [
               :id,
               :username,
               :age,
               :password,
               :bio,
               :company_id,
               :inserted_at,
               :updated_at
             ]

      with_types = fields |> Enum.map(fn field -> {field, User.__schema__(:type, field)} end)

      assert with_types == [
               {:id, :id},
               {:username, :string},
               {:age, :integer},
               {:password, :string},
               {:bio, :string},
               {:company_id, :id},
               {:inserted_at, :naive_datetime},
               {:updated_at, :naive_datetime}
             ]
    end

    test "associations" do
      associations = User.__schema__(:associations)
      assert associations == [:company, :posts, :likes]
    end

    test "associations - company" do
      company_assoc = User.__schema__(:association, :company)

      assert %Ecto.Association.BelongsTo{
               field: :company,
               owner: Dryhard.User,
               related: Dryhard.Company,
               owner_key: :company_id,
               related_key: :id,
               queryable: Dryhard.Company,
               on_cast: nil,
               on_replace: :raise,
               where: [],
               defaults: [],
               cardinality: :one,
               relationship: :parent,
               unique: true,
               ordered: false
             } == company_assoc
    end

    test "associations - posts" do
      company_assoc = User.__schema__(:association, :posts)

      assert %Ecto.Association.Has{
               cardinality: :many,
               defaults: [],
               field: :posts,
               on_cast: nil,
               on_replace: :raise,
               ordered: false,
               owner: Dryhard.User,
               owner_key: :id,
               queryable: Dryhard.Post,
               related: Dryhard.Post,
               related_key: :user_id,
               relationship: :child,
               unique: true,
               where: [],
               on_delete: :nothing,
               preload_order: []
             } == company_assoc
    end

    test "associations - likes" do
      company_assoc = User.__schema__(:association, :likes)

      assert %Ecto.Association.Has{
               cardinality: :many,
               defaults: [],
               field: :likes,
               on_cast: nil,
               on_replace: :raise,
               ordered: false,
               owner: Dryhard.User,
               owner_key: :id,
               queryable: Dryhard.Like,
               related: Dryhard.Like,
               related_key: :user_id,
               relationship: :child,
               unique: true,
               where: [],
               on_delete: :nothing,
               preload_order: []
             } == company_assoc
    end
  end
end
