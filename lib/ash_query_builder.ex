defmodule AshQueryBuilder do
  @moduledoc false

  alias AshQueryBuilder.{Filter, Sorter, ToQuery, ToParams, Parser}

  defstruct filters: [], sorters: []

  def new, do: struct!(__MODULE__, %{})

  def add_filter(builder, filter) do
    %{builder | filters: [filter] ++ builder.filters}
  end

  def add_filter(builder, field, operator, value) do
    add_filter(builder, [], field, operator, value)
  end

  def add_filter(builder, path, field, operator, value) when is_binary(operator) do
    operator = String.to_existing_atom(operator)

    add_filter(builder, path, field, operator, value)
  end

  def add_filter(builder, path, field, operator, value) when is_atom(operator) do
    filter = Filter.new(path, field, operator, value)

    %{builder | filters: [filter] ++ builder.filters}
  end

  def add_sorter(builder, sorter) do
    %{builder | sorters: [sorter] ++ builder.sorters}
  end

  def add_sorter(builder, field, order) when is_binary(order) do
    order = String.to_existing_atom(order)

    add_sorter(builder, field, order)
  end

  def add_sorter(builder, field, order) do
    sorter = Sorter.new(field, order)

    %{builder | sorters: [sorter] ++ builder.sorters}
  end

  def to_query(builder, query) do
    filters = Enum.reverse(builder.filters)
    sorters = Enum.reverse(builder.sorters)

    ToQuery.generate(query, filters, sorters)
  end

  def to_params(builder), do: ToParams.generate(builder)

  def parse(args), do: Parser.parse(args)
end
