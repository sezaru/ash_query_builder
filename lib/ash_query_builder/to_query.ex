defmodule AshQueryBuilder.ToQuery do
  @moduledoc false

  alias AshQueryBuilder.{FilterScope, Filter.Protocol}

  import Ash.Query

  def generate(query, filters, sorters) do
    filters = filters |> Enum.map(&to_expression/1) |> Enum.reject(&is_nil/1)

    {:ok, filter} = Ash.Filter.parse(query.resource, filters)

    query = Ash.Query.filter(query, expr(^filter))

    Enum.reduce(sorters, query, fn sorter, query ->
      Ash.Query.sort(query, [{sorter.field, sorter.order}], prepend?: true)
    end)
  end

  defp to_expression(%FilterScope{filters: []}), do: []

  defp to_expression(%FilterScope{filters: filters} = scope) do
    case filters |> Enum.map(&to_expression/1) |> Enum.reject(&is_nil/1) do
      [] -> []
      filters -> [{scope.operation, filters}]
    end
  end

  defp to_expression(%{enabled?: true} = filter), do: Protocol.to_expression(filter)
  defp to_expression(%{enabled?: false}), do: nil
end
