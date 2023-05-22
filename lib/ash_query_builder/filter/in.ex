defmodule AshQueryBuilder.Filter.In do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :in

  @impl true
  def new(id, path, field, value) when is_list(value),
    do: struct(__MODULE__, id: id, field: field, path: path, value: value)
end

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.In do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_filter(filter, query) do
    Ash.Query.filter(query, expr(^make_ref(filter) in ^filter.value))
  end

  def operator(_), do: AshQueryBuilder.Filter.In.operator()
end
