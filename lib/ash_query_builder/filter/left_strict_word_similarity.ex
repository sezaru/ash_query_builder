defmodule AshQueryBuilder.Filter.LeftStrictWordSimilarity do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :left_strict_word_similarity

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

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.LeftStrictWordSimilarity do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_expression(filter), do: expr(fragment("(? <<% ?)", ^make_ref(filter), ^filter.value))

  def operator(_), do: AshQueryBuilder.Filter.LeftStrictWordSimilarity.operator()
end
