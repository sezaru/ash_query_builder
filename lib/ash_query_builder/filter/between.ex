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
    case filter.value do
      [nil, high] -> expr(make_ref(^filter) <= ^high)
      [low, nil] -> expr(make_ref(^filter) >= ^low)
      [low, high] -> expr(fragment("(? between ? and ?)", make_ref(^filter), ^low, ^high))
    end
  end

  def operator(_), do: AshQueryBuilder.Filter.Between.operator()
end
