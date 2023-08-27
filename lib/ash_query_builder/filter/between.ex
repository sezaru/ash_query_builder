defmodule AshQueryBuilder.Filter.Between do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :between

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

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.Between do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_expression(filter) do
    [low, high] = filter.value

    expr(^make_ref(filter) >= ^low and ^make_ref(filter) < ^high)
  end

  def operator(_), do: AshQueryBuilder.Filter.Between.operator()
end
