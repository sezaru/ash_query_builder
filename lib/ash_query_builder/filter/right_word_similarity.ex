defmodule AshQueryBuilder.Filter.RightWordSimilarity do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :right_word_similarity

  @impl true
  def new(id, path, field, value, opts) do
    enabled? = Keyword.get(opts, :enabled?, true)

    struct(__MODULE__, id: id, field: field, path: path, value: value, enabled?: enabled?)
  end
end

defimpl AshQueryBuilder.Filter.Protocol, for: AshQueryBuilder.Filter.RightWordSimilarity do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_filter(filter, query) do
    Ash.Query.filter(query, expr(fragment("? %> ?", ^make_ref(filter), ^filter.value)))
  end

  def operator(_), do: AshQueryBuilder.Filter.RightWordSimilarity.operator()
end
