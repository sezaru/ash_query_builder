defmodule AshQueryBuilder.ToQuery do
  @moduledoc false

  alias AshQueryBuilder.{FilterScope, Filter.Protocol}

  require Ash.Query

  import Ash.Expr, only: [expr: 1]

  def generate(%Ash.Query{} = query, filters, sorters) do
    filters = filters |> Enum.map(&to_expression/1) |> Enum.reject(&is_nil/1)

    {:ok, filter} = Ash.Filter.parse(query.resource, filters)

    query = Ash.Query.filter(query, expr(^filter))

    Enum.reduce(sorters, query, fn sorter, query ->
      Ash.Query.sort(query, [{sorter.field, sorter.order}], prepend?: true)
    end)
  end

  def generate(resource, query_fn, arguments, filters, sorters) when is_function(query_fn) do
    query = Ash.Query.new(resource)

    query =
      Enum.reduce(arguments, query, fn argument, query ->
        %{name: name, value: value} = argument

        Ash.Query.set_argument(query, name, value)
      end)

    query = query_fn.(query)

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
