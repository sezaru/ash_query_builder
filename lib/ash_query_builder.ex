defmodule AshQueryBuilder do
  @moduledoc false

  alias AshQueryBuilder.{Filter, Sorter, ToQuery, ToParams, Parser}

  defstruct filters: [], sorters: []

  def new, do: struct!(__MODULE__, %{})

  def add_filter(builder, filter) do
    {%{builder | filters: [filter] ++ builder.filters}, filter}
  end

  def add_filter(builder, field, operator, value, opts) do
    add_filter(builder, [], field, operator, value, opts)
  end

  def add_filter(builder, path, field, operator, value, opts) when is_binary(operator) do
    operator = String.to_existing_atom(operator)

    add_filter(builder, path, field, operator, value, opts)
  end

  def add_filter(builder, path, field, operator, value, opts) when is_atom(operator) do
    filter = Filter.new(path, field, operator, value, opts)

    {%{builder | filters: [filter] ++ builder.filters}, filter}
  end

  def replace_filter(builder, id, field, operator, value, opts),
    do: replace_filter(builder, id, [], field, operator, value, opts)

  def replace_filter(builder, id, path, field, operator, value, opts)
      when is_integer(id) and is_binary(operator) do
    operator = String.to_existing_atom(operator)

    replace_filter(builder, id, path, field, operator, value, opts)
  end

  def replace_filter(builder, id, path, field, operator, value, opts)
      when is_integer(id) and is_atom(operator) do
    %{filters: filters} = builder

    case Enum.find_index(filters, fn filter -> filter.id == id end) do
      nil ->
        {:error, :not_found}

      index ->
        filters =
          List.update_at(filters, index, fn _ ->
            Filter.new(id, path, field, operator, value, opts)
          end)

        {:ok, %{builder | filters: filters}}
    end
  end

  def enable_filter(builder, id) when is_integer(id) do
    %{filters: filters} = builder

    case Enum.find_index(filters, fn filter -> filter.id == id end) do
      nil ->
        {:error, :not_found}

      index ->
        filters =
          List.update_at(filters, index, fn filter -> %{filter | enabled?: true} end)

        {:ok, %{builder | filters: filters}}
    end
  end

  def disable_filter(builder, id) when is_integer(id) do
    %{filters: filters} = builder

    case Enum.find_index(filters, fn filter -> filter.id == id end) do
      nil ->
        {:error, :not_found}

      index ->
        filters =
          List.update_at(filters, index, fn filter -> %{filter | enabled?: true} end)

        {:ok, %{builder | filters: filters}}
    end
  end

  def remove_filter(builder, id) do
    filters = Enum.reject(builder.filters, fn filter -> filter.id == id end)

    %{builder | filters: filters}
  end

  def add_sorter(builder, sorter) do
    {%{builder | sorters: [sorter] ++ builder.sorters}, sorter}
  end

  def add_sorter(builder, field, order) when is_binary(order) do
    order = String.to_existing_atom(order)

    add_sorter(builder, field, order)
  end

  def add_sorter(builder, field, order) do
    sorter = Sorter.new(field, order)

    {%{builder | sorters: [sorter] ++ builder.sorters}, sorter}
  end

  def replace_sorter(builder, id, field, order) when is_integer(id) and is_binary(order) do
    order = String.to_existing_atom(order)

    replace_sorter(builder, id, field, order)
  end

  def replace_sorter(builder, id, field, order) when is_integer(id) and is_atom(order) do
    %{sorters: sorters} = builder

    case Enum.find_index(sorters, fn sorter -> sorter.id == id end) do
      nil ->
        {:error, :not_found}

      index ->
        sorters = List.update_at(sorters, index, fn _ -> Sorter.new(id, field, order) end)

        {:ok, %{builder | sorters: sorters}}
    end
  end

  def remove_sorter(builder, id) do
    sorters = Enum.reject(builder.sorters, fn filter -> filter.id == id end)

    %{builder | sorters: sorters}
  end

  def to_query(builder, query) do
    filters = Enum.reverse(builder.filters)
    sorters = Enum.reverse(builder.sorters)

    ToQuery.generate(query, filters, sorters)
  end

  def to_params(builder, opts \\ []), do: ToParams.generate(builder, opts)

  def parse(args), do: Parser.parse(args)
end
