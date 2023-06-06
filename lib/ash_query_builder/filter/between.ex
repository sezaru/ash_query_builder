defmodule AshQueryBuilder.Filter.Between do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :between

  @impl true
  def new(id, path, field, value),
    do: struct(__MODULE__, id: id, field: field, path: path, value: value)
end

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.Between do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_filter(filter, query) do
    [low, high] = filter.value
    Ash.Query.filter(query, expr(^make_ref(filter) >= ^low and ^make_ref(filter) < ^high))
  end

  def operator(_), do: AshQueryBuilder.Filter.Between.operator()
end
