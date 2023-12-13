defmodule Dryhard do
  @moduledoc """
  Documentation for `Dryhard`.
  """

  defmacro __using__(_) do
    quote do
      require Dryhard
      import Ecto.Query, warn: false, only: [from: 2]
    end
  end

  defmacro list(config) do
    quote bind_quoted: [config: config] do
      def unquote(:"list_#{config.plural_name}")(queries \\ & &1) do
        unquote(config.schema)
        |> queries.()
        |> unquote(config.repo).all()
      end
    end
  end

  defmacro base(config) do
    quote bind_quoted: [config: config] do
      @doc """
      Initial query for #{config.plural_name}. Like: `from(u in User)`
      """
      def unquote(:"base_#{config.plural_name}")(queries \\ & &1) do
        unquote(config.schema).__schema__(:query)
        |> queries.()
      end
    end
  end

  defmacro paginate(config) do
    quote bind_quoted: [config: config] do
      @doc """
      Pagination for #{config.plural_name}.

      Params:
        - page: integer
        - per_page: integer
        - queries: function that accepts an Ecto.Query for further filtering
      """
      def unquote(:"paginate_#{config.plural_name}")(queries \\ & &1, page \\ 1, page_size \\ 25) do
        unquote(config.schema)
        |> queries.()
        |> Dryhard.Pager.page(unquote(config.repo), page, page_size)
      end
    end
  end

  defmacro get!(config) do
    quote bind_quoted: [config: config] do
      @doc """
      Hard get for a single record of #{config.plural_name}.

      Params:
        - id: integer / uuid / etc
        - queries: function that accepts an Ecto.Query for further filtering
      """
      def unquote(:"get_#{config.singular_name}!")(id, queries \\ & &1) do
        unquote(config.schema)
        |> queries.()
        |> unquote(config.repo).get!(id)
      end
    end
  end

  defmacro get(config) do
    quote bind_quoted: [config: config] do
      @doc """
      Soft get for a single record of #{config.plural_name}.

      Params:
        - id: integer / uuid / etc
        - queries: function that accepts an Ecto.Query for further filtering
      """
      def unquote(:"get_#{config.singular_name}")(id, queries \\ & &1) do
        unquote(config.schema)
        |> queries.()
        |> unquote(config.repo).get(id)
      end
    end
  end

  defmacro get_by_attr!(config, attr_name) do
    quote bind_quoted: [config: config, attr_name: attr_name] do
      @doc """
      Hard get a single record of #{config.plural_name} by #{attr_name}
      Params:
        - value: value for #{attr_name}
        - queries: function that accepts an Ecto.Query for further filtering
      """
      def unquote(:"get_#{config.singular_name}_by_#{attr_name}!")(value, queries \\ & &1) do
        unquote(config.schema)
        |> queries.()
        |> unquote(config.repo).get_by!([{unquote(attr_name), value}])
      end
    end
  end

  defmacro get_by_attr(config, attr_name) do
    quote bind_quoted: [config: config, attr_name: attr_name] do
      @doc """
      Soft get a single record of #{config.plural_name} by #{attr_name}
      Params:
        - value: value for #{attr_name}
        - queries: function that accepts an Ecto.Query for further filtering
      """
      def unquote(:"get_#{config.singular_name}_by_#{attr_name}")(value, queries \\ & &1) do
        unquote(config.schema)
        |> queries.()
        |> unquote(config.repo).get_by([{unquote(attr_name), value}])
      end
    end
  end

  defmacro get_for!(config, assoc_name) do
    quote bind_quoted: [config: config, assoc_name: assoc_name] do
      @doc """
      Hard get a single record of #{config.plural_name} for #{assoc_name}
      Params:
        - assoc_record: instance of #{assoc_name}
        - queries: function that accepts an Ecto.Query for further filtering
      """
      def unquote(:"get_#{config.singular_name}_for_#{assoc_name}!")(
            assoc_record,
            queries \\ & &1
          ) do
        foreign_key =
          unquote(config.schema).__schema__(:association, unquote(assoc_name)).owner_key

        from(resource in unquote(config.schema),
          where: field(resource, ^foreign_key) == ^assoc_record.id
        )
        |> queries.()
        |> unquote(config.repo).one!()
      end
    end
  end

  defmacro get_for(config, assoc_name) do
    quote bind_quoted: [config: config, assoc_name: assoc_name] do
      @doc """
      Soft get a single record of #{config.plural_name} for #{assoc_name}

      Params:
        - assoc_record: instance of #{assoc_name}
        - queries: function that accepts an Ecto.Query for further filtering
      """
      def unquote(:"get_#{config.singular_name}_for_#{assoc_name}")(assoc_record, queries \\ & &1) do
        foreign_key =
          unquote(config.schema).__schema__(:association, unquote(assoc_name)).owner_key

        from(resource in unquote(config.schema),
          where: field(resource, ^foreign_key) == ^assoc_record.id
        )
        |> queries.()
        |> unquote(config.repo).one()
      end
    end
  end

  defmacro new(config) do
    quote bind_quoted: [config: config] do
      @doc """
      Returns a new struct of #{config.plural_name}
      """
      def unquote(:"new_#{config.singular_name}")() do
        unquote(config.schema) |> struct()
      end
    end
  end

  defmacro upsert(config, changeset_fn, opts \\ [on_conflict: :nothing]) do
    quote bind_quoted: [config: config, changeset_fn: changeset_fn, opts: opts] do
      @doc """
      Creates a single #{config.plural_name} record (ignores conflicts, like ID / uniq indexes)
      Provide upsert options as documented here:
        - https://hexdocs.pm/ecto/Ecto.Repo.html#c:insert/2-upserts

      Defaults to:
        `[on_conflict: :nothing]`

      Params:
        - attrs: map to pass into the changeset function
      """
      def unquote(:"upsert_#{config.singular_name}")(attrs) do
        unquote(config.schema)
        |> struct()
        |> unquote(changeset_fn).(attrs)
        |> unquote(config.repo).insert(unquote(opts))
      end
    end
  end

  defmacro create(config, changeset_fn) do
    quote bind_quoted: [config: config, changeset_fn: changeset_fn] do
      @doc """
      Creates a single #{config.plural_name} record

      Params:
        - attrs: map to pass into the changeset function
      """
      def unquote(:"create_#{config.singular_name}")(attrs) do
        unquote(config.schema)
        |> struct()
        |> unquote(changeset_fn).(attrs)
        |> unquote(config.repo).insert()
      end
    end
  end

  defmacro create(config, association_name, changeset_fn) do
    quote bind_quoted: [
            config: config,
            association_name: association_name,
            changeset_fn: changeset_fn
          ] do
      association_schema = config.schema.__schema__(:association, association_name).queryable

      def unquote(:"create_#{config.singular_name}")(association_struct, attrs) do
        association_foreign_key =
          unquote(config.schema).__schema__(:association, unquote(association_name)).owner_key
          |> Atom.to_string()

        attrs = Map.merge(attrs, %{association_foreign_key => association_struct.id})

        unquote(config.schema)
        |> struct()
        |> unquote(changeset_fn).(attrs)
        |> unquote(config.repo).insert()
      end
    end
  end

  defmacro change(config, changeset_fn) do
    quote bind_quoted: [config: config, changeset_fn: changeset_fn] do
      def unquote(:"change_#{config.singular_name}")(resource, attrs) do
        unquote(changeset_fn).(resource, attrs)
      end
    end
  end

  defmacro update(config, changeset_fn) do
    quote bind_quoted: [config: config, changeset_fn: changeset_fn] do
      def unquote(:"update_#{config.singular_name}")(resource, attrs) do
        resource
        |> unquote(changeset_fn).(attrs)
        |> unquote(config.repo).update()
      end
    end
  end

  defmacro delete(config) do
    quote bind_quoted: [config: config] do
      def unquote(:"delete_#{config.singular_name}")(resource) do
        unquote(config.repo).delete(resource)
      end
    end
  end

  defmacro preload(config, preload_assoc_name) do
    quote bind_quoted: [config: config, preload_assoc_name: preload_assoc_name] do
      def unquote(:"preload_#{config.singular_name}_#{preload_assoc_name}")(query) do
        from(query, preload: unquote(preload_assoc_name))
      end
    end
  end

  defmacro join(config, join_assoc_name) do
    quote bind_quoted: [config: config, join_assoc_name: join_assoc_name] do
      def unquote(:"join_#{config.singular_name}_#{join_assoc_name}")(query) do
        from(resource in query,
          join: assoc_resource in assoc(resource, unquote(join_assoc_name)),
          preload: [{unquote(join_assoc_name), assoc_resource}]
        )
      end
    end
  end

  defmacro order_by(config, attr_name, direction) do
    quote bind_quoted: [config: config, attr_name: attr_name, direction: direction] do
      def unquote(:"order_#{config.plural_name}_by_#{attr_name}")(query) do
        from(query, order_by: [{unquote(direction), unquote(attr_name)}])
      end
    end
  end

  defmacro filter_by_one(config, assoc_name) do
    quote bind_quoted: [config: config, assoc_name: assoc_name] do
      def unquote(:"filter_#{config.plural_name}_by_#{assoc_name}")(query, assoc_record) do
        foreign_key =
          unquote(config.schema).__schema__(:association, unquote(assoc_name)).owner_key

        from(resource in query, where: field(resource, ^foreign_key) == ^assoc_record.id)
      end
    end
  end

  defmacro filter_by_many(config, assoc_name) do
    quote bind_quoted: [config: config, assoc_name: assoc_name] do
      def unquote(:"filter_#{config.plural_name}_by_#{assoc_name}")(query, assoc_records) do
        foreign_key =
          unquote(config.schema).__schema__(:association, unquote(assoc_name)).owner_key

        assoc_ids = Enum.map(assoc_records, & &1.id)
        from(resource in query, where: field(resource, ^foreign_key) in ^assoc_ids)
      end
    end
  end

  defmacro filter_by_one_or_many(config, assoc_name) do
    quote bind_quoted: [config: config, assoc_name: assoc_name] do
      def unquote(:"filter_#{config.plural_name}_by_#{assoc_name}")(
            query,
            assoc_record_or_records
          ) do
        foreign_key =
          unquote(config.schema).__schema__(:association, unquote(assoc_name)).owner_key

        assoc_ids =
          assoc_record_or_records
          |> List.wrap()
          |> Enum.map(& &1.id)

        from(resource in query, where: field(resource, ^foreign_key) in ^assoc_ids)
      end
    end
  end

  def config(schema, repo, plural) do
    resource_name = Dryhard.Naming.resource_name(schema)

    %{
      singular_name: resource_name,
      plural_name: plural,
      schema: schema,
      repo: repo
    }
  end
end
