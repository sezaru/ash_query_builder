defmodule AshQueryBuilder.Filter.Equal do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :==

  @impl true
  def new(id, path, field, value),
    do: struct(__MODULE__, id: id, field: field, path: path, value: value)
end

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.Equal do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_filter(filter, query) do
    Ash.Query.filter(query, expr(^make_ref(filter) == ^filter.value))
  end

  def operator(_), do: AshQueryBuilder.Filter.Equal.operator()
end
