defmodule Dryhard.Testing do
  @moduledoc """
  Documentation for `Dryhard.Testing`.
  Based on suggestions from
  - https://elixirforum.com/t/prototyping-and-enforcing-context-function-conventions/38821/2
  """
  defmacro list(config) do
    quote do
      test "list_#{unquote(config).plural_name}" do
        Dryhard.Testing.check_list(unquote(config))
      end
    end
  end

  defmacro get(config) do
    quote do
      test "get_#{unquote(config).singular_name}" do
        Dryhard.Testing.check_get(unquote(config))
      end
    end
  end

  defmacro get!(config) do
    quote do
      test "get_#{unquote(config).singular_name}!" do
        Dryhard.Testing.check_get!(unquote(config))
      end
    end
  end

  defmacro new(config) do
    quote do
      test "new_#{unquote(config).singular_name}" do
        Dryhard.Testing.check_new(unquote(config))
      end
    end
  end

  defmacro change(config) do
    quote do
      test "change_#{unquote(config).singular_name}" do
        Dryhard.Testing.check_change(unquote(config))
      end
    end
  end

  defmacro create(config, attrs) do
    quote do
      test "create_#{unquote(config).singular_name}" do
        Dryhard.Testing.check_create(unquote(config), unquote(attrs), fn _config -> %{} end)
      end
    end
  end

  defmacro create(config, attrs, extra_attrs_fun) do
    quote do
      test "create_#{unquote(config).singular_name}" do
        Dryhard.Testing.check_create(unquote(config), unquote(attrs), unquote(extra_attrs_fun))
      end
    end
  end

  defmacro update(config, attrs) do
    quote do
      test "update_#{unquote(config).singular_name}" do
        Dryhard.Testing.check_update(unquote(config), unquote(attrs), fn _config -> %{} end)
      end
    end
  end

  defmacro update(config, attrs, extra_attrs_fun) do
    quote do
      test "update_#{unquote(config).singular_name}" do
        Dryhard.Testing.check_update(unquote(config), unquote(attrs), unquote(extra_attrs_fun))
      end
    end
  end

  defmacro delete(config) do
    quote do
      test "delete_#{unquote(config).singular_name}" do
        Dryhard.Testing.check_delete(unquote(config))
      end
    end
  end

  defmacro paginate(config) do
    quote do
      test "paginate_#{unquote(config).singular_name}" do
        Dryhard.Testing.check_paginate(unquote(config))
      end
    end
  end

  import ExUnit.Assertions

  def check_list(config) do
    config.factory.insert(config.factory_name)
    config.factory.insert(config.factory_name)
    res = apply(config.context, :"list_#{config.plural_name}", [])
    assert Enum.count(res) == 2
  end

  def check_get(config) do
    rec1 = config.factory.insert(config.factory_name)
    # returns plain record for found items
    res = apply(config.context, :"get_#{config.singular_name}", [rec1.id])
    assert rec1.id == res.id

    # returns nil for non-found items
    res = apply(config.context, :"get_#{config.singular_name}", [-1])
    assert res == nil
  end

  def check_get!(config) do
    rec1 = config.factory.insert(config.factory_name)

    # returns plain record for found items
    res = apply(config.context, :"get_#{config.singular_name}!", [rec1.id])
    assert rec1.id == res.id

    # raises for non-found items
    assert_raise Ecto.NoResultsError, fn ->
      apply(config.context, :"get_#{config.singular_name}!", [-1])
    end
  end

  def check_new(config) do
    res = apply(config.context, :"new_#{config.singular_name}", [])
    assert res.__struct__ == config.schema
  end

  def check_change(config) do
    rec1 = config.factory.insert(config.factory_name)
    res = apply(config.context, :"change_#{config.singular_name}", [rec1, %{}])
    assert res.__struct__ == Ecto.Changeset
  end

  def check_create(config, attrs, extra_attrs_fun) do
    extra_attrs = extra_attrs_fun.(config)
    full_attrs = Map.merge(attrs, extra_attrs)
    {:ok, res} = apply(config.context, :"create_#{config.singular_name}", [full_attrs])
    rec1 = config.repo.get(config.schema, res.id)
    assert rec1.id == res.id
  end

  def check_update(config, attrs, extra_attrs_fun) do
    extra_attrs = extra_attrs_fun.(config)
    full_attrs = Map.merge(attrs, extra_attrs)
    rec1 = config.factory.insert(config.factory_name)
    {:ok, res} = apply(config.context, :"update_#{config.singular_name}", [rec1, full_attrs])

    Enum.each(attrs, fn {k, v} ->
      # IO.puts("K: #{k}, V: #{Map.get(res, k)}")
      assert Map.get(res, k) == v
    end)
  end

  def check_delete(config) do
    rec1 = config.factory.insert(config.factory_name)
    {:ok, _res} = apply(config.context, :"delete_#{config.singular_name}", [rec1])
    assert nil == config.repo.get(config.schema, rec1.id)
  end

  def check_paginate(config) do
    for _i <- 1..3 do
      config.factory.insert(config.factory_name)
    end

    res = apply(config.context, :"paginate_#{config.plural_name}", [& &1, 2, 2])

    assert %{
             count: 3,
             first: 3,
             has_next: false,
             has_prev: true,
             last: 3,
             next_page: 3,
             page: 2,
             prev_page: 1
           } = res

    res = apply(config.context, :"paginate_#{config.plural_name}", [& &1, 3, 2])

    assert %{
             count: 3,
             first: 5,
             has_next: false,
             has_prev: true,
             last: 3,
             list: [],
             next_page: 4,
             page: 3,
             prev_page: 2
           } = res
  end

  def config(context, opts) do
    repo = Keyword.fetch!(opts, :repo)
    schema = Keyword.fetch!(opts, :schema)
    plural = Keyword.fetch!(opts, :plural)
    factory = Keyword.fetch!(opts, :factory)
    resource_name = Dryhard.Naming.resource_name(schema)
    factory_name = Keyword.get(opts, :factory_name, :"#{resource_name}")

    %{
      context: context,
      singular_name: resource_name,
      plural_name: plural,
      schema: schema,
      factory_name: factory_name,
      factory: factory,
      repo: repo
    }
  end
end
