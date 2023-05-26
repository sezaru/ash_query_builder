defmodule AshQueryBuilder.Parser do
  @moduledoc false

  def parse(args) when is_map(args) do
    sorters = Map.get(args, "s", %{})
    filters = Map.get(args, "f", %{})

    AshQueryBuilder.new()
    |> parse_filters(filters)
    |> parse_sorters(sorters)
  end

  defp parse_filters(builder, filters) do
    filters
    |> Enum.sort_by(fn {id, _} -> id end)
    |> Enum.reduce(builder, fn {id, values}, builder ->
      id = String.to_integer(id)

      %{"f" => field, "o" => operator, "v" => value} = values

      path = values |> Map.get("p", []) |> Enum.map(&String.to_existing_atom/1)
      field = String.to_existing_atom(field)
      operator = String.to_existing_atom(operator)

      filter = AshQueryBuilder.Filter.new(id, path, field, operator, value)

      AshQueryBuilder.add_filter(builder, filter)
    end)
  end

  defp parse_sorters(builder, sorters) do
    sorters
    |> Enum.sort_by(fn {id, _} -> id end)
    |> Enum.reduce(builder, fn {id, values}, builder ->
      id = String.to_integer(id)

      %{"f" => field, "o" => order} = values

      field = String.to_existing_atom(field)
      order = String.to_existing_atom(order)

      sorter = AshQueryBuilder.Sorter.new(id, field, order)

      AshQueryBuilder.add_sorter(builder, sorter)
    end)
  end
end
