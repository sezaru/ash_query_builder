defmodule AshQueryBuilder.ToParams do
  @moduledoc false

  alias AshQueryBuilder.Filter.Protocol

  def generate(builder, opts) do
    with_disabled? = Keyword.get(opts, :with_disabled?, false)

    filters = filters_to_params(builder.filters, with_disabled?)
    sorters = sorters_to_params(builder.sorters)

    %{"f" => filters, "s" => sorters}
  end

  defp filters_to_params(filters, with_disabled?) do
    filters
    |> maybe_filter_out_disabled(with_disabled?)
    |> Enum.map(fn filter ->
      values = %{
        "p" => filter.path,
        "f" => filter.field,
        "o" => Protocol.operator(filter),
        "v" => filter.value
      }

      values = maybe_add_enabled_flag(values, filter, with_disabled?)

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

  defp maybe_filter_out_disabled(filters, false), do: Enum.filter(filters, & &1.enabled?)
  defp maybe_filter_out_disabled(filters, true), do: filters

  defp maybe_add_enabled_flag(values, _, false), do: values
  defp maybe_add_enabled_flag(values, filter, true), do: Map.put(values, "e", filter.enabled?)
end
