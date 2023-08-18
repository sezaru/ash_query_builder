defmodule AshQueryBuilder.Parser do
  @moduledoc false

  alias AshQueryBuilder.{Filter, Sorter}

  def parse(args) do
    args = args |> Base.decode64!() |> :erlang.binary_to_term()

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
      %{"f" => field, "o" => operator, "v" => value} = values

      enabled? = Map.get(values, "e", true)
      metadata = Map.get(values, "m")

      path = Map.get(values, "p", [])

      filter =
        Filter.new(id, path, field, operator, value, enabled?: enabled?, metadata: metadata)

      AshQueryBuilder.add_filter(builder, filter)
    end)
  end

  defp parse_sorters(builder, sorters) do
    sorters
    |> Enum.sort_by(fn {id, _} -> id end)
    |> Enum.reduce(builder, fn {id, values}, builder ->
      %{"f" => field, "o" => order} = values

      sorter = Sorter.new(id, field, order)

      AshQueryBuilder.add_sorter(builder, sorter)
    end)
  end
end
