defmodule AshQueryBuilder.Filter.InArray do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :in_array

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

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.InArray do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_expression(filter), do: expr(fragment("(? = any(?))", ^filter.value, ^make_ref(filter)))

  def operator(_), do: AshQueryBuilder.Filter.InArray.operator()
end
