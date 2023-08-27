defmodule AshQueryBuilder.Parser do
  @moduledoc false

  alias AshQueryBuilder.{Filter, FilterScope, Sorter}

  def parse(args) do
    args = args |> Base.decode64!() |> :erlang.binary_to_term()

    sorters = Map.get(args, :s, %{})
    filters = Map.get(args, :f, %{})

    AshQueryBuilder.new()
    |> parse_filters(filters)
    |> parse_sorters(sorters)
  end

  defp parse_filters(builder_or_scope, filters, add_filter_fn \\ &AshQueryBuilder.add_filter/2) do
    filters
    |> Enum.sort_by(fn {id, _} -> id end)
    |> Enum.reduce(builder_or_scope, fn
      {id, %{t: :scope} = values}, builder_or_scope ->
        parse_scope(builder_or_scope, id, values, add_filter_fn)

      {id, %{t: :filter} = values}, builder_or_scope ->
        parse_filter(builder_or_scope, id, values, add_filter_fn)
    end)
  end

  defp parse_scope(builder_or_scope, id, values, add_filter_fn) do
    %{o: operation, f: filters} = values

    scope =
      operation |> FilterScope.new(id: id) |> parse_filters(filters, &FilterScope.add_filter/2)

    add_filter_fn.(builder_or_scope, scope)
  end

  defp parse_filter(builder_or_scope, id, values, add_filter_fn) do
    %{f: field, o: operator, v: value} = values

    enabled? = Map.get(values, :e, true)
    metadata = Map.get(values, :m)

    path = Map.get(values, :p, [])

    filter =
      Filter.new(id, path, field, operator, value, enabled?: enabled?, metadata: metadata)

    add_filter_fn.(builder_or_scope, filter)
  end

  defp parse_sorters(builder, sorters) do
    sorters
    |> Enum.sort_by(fn {id, _} -> id end)
    |> Enum.reduce(builder, fn {id, values}, builder ->
      %{f: field, o: order} = values

      sorter = Sorter.new(id, field, order)

      AshQueryBuilder.add_sorter(builder, sorter)
    end)
  end
end
