defmodule Dryhard.Pager do
  import Ecto.Query, warn: false

  @moduledoc """
  Documentation for `Pager`.
  """

  def page(query, repo, nil, per_page) do
    page(query, repo, 1, per_page)
  end

  def page(query, repo, page, per_page) when is_nil(per_page) or per_page == "" do
    page(query, repo, page, 50)
  end

  def page(query, repo, page, per_page) do
    do_page(query, repo, ensure_integer(page), ensure_integer(per_page))
  end

  defp do_page(query, repo, page, per_page) do
    results = query(query, repo, page, per_page: per_page)
    count = total_count(query, repo)
    first = (page - 1) * per_page + 1

    %{
      count: count,
      first: first,
      has_next: length(results) > per_page,
      has_prev: page > 1,
      last: Enum.min([page * per_page, count]),
      list: Enum.slice(results, 0, per_page),
      page: page,
      prev_page: page - 1,
      next_page: page + 1
    }
  end

  defp total_count(query, repo) do
    q =
      query
      |> exclude(:preload)
      |> exclude(:order_by)

    repo.one(from(t in subquery(q), select: count("*")))
  end

  def ensure_integer(str) when is_binary(str), do: String.to_integer(str)
  def ensure_integer(int) when is_integer(int), do: int

  defp query(query, repo, page, per_page: per_page) do
    query
    |> limit(^(per_page + 1))
    |> offset(^(per_page * (page - 1)))
    |> repo.all()
  end
end
