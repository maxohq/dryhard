defmodule DryhardCompanyTest do
  use ExUnit.Case, async: true
  alias Dryhard.{Repo, Company}

  defmodule CompanyContext do
    require Dryhard
    import Ecto.Query
    @resource Dryhard.config(Company, Repo, "companies")

    # Common CRUD functions
    Dryhard.list(@resource)
    Dryhard.get!(@resource)
    Dryhard.get(@resource)
    Dryhard.new(@resource)
    Dryhard.create(@resource, &Company.changeset/2)
    Dryhard.change(@resource, &Company.changeset/2)
    Dryhard.update(@resource, &Company.changeset/2)
    Dryhard.delete(@resource)

    # CRUD helpers
    Dryhard.paginate(@resource)
    Dryhard.get_by_attr!(@resource, :name)
    Dryhard.get_by_attr(@resource, :name)
    Dryhard.preload(@resource, :users)
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

  require Dryhard.Testing

  @resource Dryhard.Testing.config(CompanyContext,
              schema: Company,
              repo: Repo,
              plural: "companies",
              factory: Dryhard.Factory
            )
  Dryhard.Testing.list(@resource)
  Dryhard.Testing.get(@resource)
  Dryhard.Testing.get!(@resource)
  Dryhard.Testing.create(@resource, %{name: "Company 1"})
  Dryhard.Testing.update(@resource, %{name: "Company 1"})
  Dryhard.Testing.delete(@resource)
  Dryhard.Testing.paginate(@resource)

  test "list" do
    Dryhard.Factory.insert(:company)
    res = CompanyContext.list_companies()
    assert Enum.count(res) == 1
  end
end
