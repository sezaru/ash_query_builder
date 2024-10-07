defmodule AshQueryBuilder do
  @moduledoc false

  alias AshQueryBuilder.{Helper, Sorter, ToQuery, ToParams, Parser}

  defstruct filters: [], sorters: []

  def new, do: struct!(__MODULE__, %{})

  defdelegate add_filter(builder, filter), to: Helper

  defdelegate replace_filter(builder, filter), to: Helper

  defdelegate add_or_replace_filter(builder, filter), to: Helper

  defdelegate find_filter(builder, id, opts \\ []), to: Helper

  defdelegate remove_filter(builder, id), to: Helper

  defdelegate reset_filters(builder), to: Helper

  def enable_filter(%{filters: filters} = builder, id) do
    with {:ok, filters} <- find_and_update(filters, &(&1.id == id), &%{&1 | enabled?: true}) do
      {:ok, %{builder | filters: filters}}
    end
  end

  def disable_filter(%{filters: filters} = builder, id) do
    with {:ok, filters} <- find_and_update(filters, &(&1.id == id), &%{&1 | enabled?: false}) do
      {:ok, %{builder | filters: filters}}
    end
  end

  def add_sorter(%{sorters: sorters} = builder, %Sorter{} = sorter),
    do: %{builder | sorters: [sorter] ++ sorters}

  def replace_sorter(%{sorters: sorters} = builder, %Sorter{} = sorter) do
    with {:ok, sorters} <- find_and_update(sorters, &(&1.id == sorter.id), fn _ -> sorter end) do
      {:ok, %{builder | sorters: sorters}}
    end
  end

  def add_or_replace_sorter(builder, sorter) do
    case replace_sorter(builder, sorter) do
      {:error, :not_found} -> add_sorter(builder, sorter)
      {:ok, builder} -> builder
    end
  end

  def find_sorter(%{sorters: sorters}, id),
    do: Enum.find(sorters, fn sorter -> sorter.id == id end)

  def remove_sorter(builder, id) do
    sorters = Enum.reject(builder.sorters, fn sorter -> sorter.id == id end)

    %{builder | sorters: sorters}
  end

  def reset_sorters(builder), do: %{builder | sorters: []}

  def to_query(builder, query) do
    filters = Enum.reverse(builder.filters)
    sorters = Enum.reverse(builder.sorters)

    ToQuery.generate(query, filters, sorters)
  end

  def to_params(builder, opts \\ []), do: ToParams.generate(builder, opts)

  def parse(args, default \\ AshQueryBuilder.new()), do: Parser.parse(args, default)

  defp find_and_update(list, find_fn, update_fn) do
    case Enum.find_index(list, find_fn) do
      nil -> {:error, :not_found}
      index -> {:ok, List.update_at(list, index, update_fn)}
    end
  end
end
