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
      id = maybe_process_id(filter.id)

      values = %{
        "p" => filter.path,
        "f" => filter.field,
        "o" => Protocol.operator(filter),
        "v" => filter.value
      }

      values =
        values |> maybe_add_enabled_flag(filter, with_disabled?) |> maybe_add_metadata(filter)

      {id, values}
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

  defp maybe_process_id(id) when is_integer(id), do: id
  defp maybe_process_id(id) when is_binary(id), do: "id:#{id}"

  defp maybe_filter_out_disabled(filters, false), do: Enum.filter(filters, & &1.enabled?)
  defp maybe_filter_out_disabled(filters, true), do: filters

  defp maybe_add_enabled_flag(values, _, false), do: values
  defp maybe_add_enabled_flag(values, filter, true), do: Map.put(values, "e", filter.enabled?)

  defp maybe_add_metadata(values, %{metadata: nil}), do: values
  defp maybe_add_metadata(values, %{metadata: metadata}), do: Map.put(values, "m", metadata)
end
