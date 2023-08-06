defmodule AshQueryBuilder.Filter.LessThan do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :<

  @impl true
  def new(id, path, field, value, opts) do
    enabled? = Keyword.get(opts, :enabled?, true)
    metadata = Keyword.get(opts, :metadata)

    struct(__MODULE__,
      id: id,
      field: field,
      path: path,
      value: value,
      enabled?: enabled?,
      metadata: metadata
    )
  end
end

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.LessThan do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_filter(filter, query) do
    Ash.Query.filter(query, expr(^make_ref(filter) < ^filter.value))
  end

  def operator(_), do: AshQueryBuilder.Filter.LessThan.operator()
end
