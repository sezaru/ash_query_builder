defmodule AshQueryBuilder.ToQuery do
  @moduledoc false

  alias AshQueryBuilder.Filter.Protocol

  def generate(query, filters, sorters) do
    query = Enum.reduce(filters, query, &Protocol.to_filter/2)

    Enum.reduce(sorters, query, fn sorter, query ->
      Ash.Query.sort(query, [{sorter.field, sorter.order}])
    end)
  end
end
