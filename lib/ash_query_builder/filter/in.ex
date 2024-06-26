defmodule AshQueryBuilder.Filter.In do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :in

  @impl true
  def new(id, path, field, value, opts) when is_list(value) do
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

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.In do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_expression(filter), do: expr(make_ref(^filter) in ^filter.value)

  def operator(_), do: AshQueryBuilder.Filter.In.operator()
end
