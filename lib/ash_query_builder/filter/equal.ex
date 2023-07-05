defmodule AshQueryBuilder.Filter.Equal do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :==

  @impl true
  def new(id, path, field, value, opts) do
    enabled? = Keyword.get(opts, :enabled?, true)

    struct(__MODULE__, id: id, field: field, path: path, value: value, enabled?: enabled?)
  end
end

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.Equal do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_filter(filter, query) do
    Ash.Query.filter(query, expr(^make_ref(filter) == ^filter.value))
  end

  def operator(_), do: AshQueryBuilder.Filter.Equal.operator()
end
