defmodule AshQueryBuilder.ToParams do
  @moduledoc false

  alias AshQueryBuilder.Filter.Protocol

  def generate(builder) do
    filters = filters_to_params(builder.filters)
    sorters = sorters_to_params(builder.sorters)

    %{"f" => filters, "s" => sorters}
  end

  defp filters_to_params(filters) do
    filters
    |> Enum.map(fn filter ->
      values = %{
        "p" => filter.path,
        "f" => filter.field,
        "o" => Protocol.operator(filter),
        "v" => filter.value
      }

      {filter.id, values}
    end)
    |> Enum.into(%{})
  end

  defp sorters_to_params(sorters) do
    sorters
    |> Enum.map(fn sorter ->
      {sorter.id, %{"f" => sorter.field, "o" => sorter.order}}
    end)
    |> Enum.into(%{})
  end
end
