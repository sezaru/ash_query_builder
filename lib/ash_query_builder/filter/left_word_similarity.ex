defmodule AshQueryBuilder.Filter.LeftWordSimilarity do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :left_word_similarity

  @impl true
  def new(id, path, field, value),
    do: struct(__MODULE__, id: id, field: field, path: path, value: value)
end

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.LeftWordSimilarity do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_filter(filter, query) do
    Ash.Query.filter(query, expr(fragment("? <% ?", ^make_ref(filter), ^filter.value)))
  end

  def operator(_), do: AshQueryBuilder.Filter.LeftWordSimilarity.operator()
end
