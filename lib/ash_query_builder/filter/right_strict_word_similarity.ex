defmodule AshQueryBuilder.Filter.RightStrictWordSimilarity do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :right_strict_word_similarity

  @impl true
  def new(id, path, field, value),
    do: struct(__MODULE__, id: id, field: field, path: path, value: value)
end

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.RightStrictWordSimilarity do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_filter(filter, query) do
    Ash.Query.filter(query, expr(fragment("? %>> ?", ^make_ref(filter), ^filter.value)))
  end

  def operator(_), do: AshQueryBuilder.Filter.RightStrictWordSimilarity.operator()
end
