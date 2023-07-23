defmodule AshQueryBuilder.ToQuery do
  @moduledoc false

  alias AshQueryBuilder.Filter.Protocol

  def generate(query, filters, sorters) do
    query = filters |> Enum.filter(& &1.enabled?) |> Enum.reduce(query, &Protocol.to_filter/2)

    Enum.reduce(sorters, query, fn sorter, query ->
      Ash.Query.sort(query, [{sorter.field, sorter.order}], prepend?: true)
    end)
  end
end
