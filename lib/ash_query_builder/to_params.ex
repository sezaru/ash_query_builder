defmodule AshQueryBuilder.ToParams do
  @moduledoc false

  alias AshQueryBuilder.{FilterScope, Filter.Protocol}

  def generate(builder, opts) do
    with_disabled? = Keyword.get(opts, :with_disabled?, false)

    arguments = arguments_to_params(builder.arguments)
    filters = filters_to_params(builder.filters, with_disabled?)
    sorters = sorters_to_params(builder.sorters)

    params = %{a: arguments, f: filters, s: sorters}

    params |> :erlang.term_to_binary([{:compressed, 1}]) |> Base.encode64()
  end

  defp arguments_to_params(arguments) do
    arguments
    |> Enum.map(fn argument ->
      values = %{v: argument.value} |> maybe_add_metadata(argument)

      {argument.name, values}
    end)
    |> Enum.into(%{})
  end

  defp filters_to_params(filters, with_disabled?) do
    filters
    |> maybe_filter_out_disabled(with_disabled?)
    |> Enum.map(fn
      %FilterScope{} = scope ->
        id = scope.id

        values = %{
          o: scope.operation,
          f: filters_to_params(scope.filters, with_disabled?),
          t: :scope
        }

        {id, values}

      filter ->
        id = filter.id

        values = %{
          p: filter.path,
          f: filter.field,
          o: Protocol.operator(filter),
          v: filter.value,
          t: :filter
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
      id = sorter.id

      {id, %{f: sorter.field, o: sorter.order}}
    end)
    |> Enum.into(%{})
  end

  defp maybe_filter_out_disabled(filters, false), do: Enum.filter(filters, & &1.enabled?)
  defp maybe_filter_out_disabled(filters, true), do: filters

  defp maybe_add_enabled_flag(values, _, false), do: values
  defp maybe_add_enabled_flag(values, filter, true), do: Map.put(values, :e, filter.enabled?)

  defp maybe_add_metadata(values, %{metadata: nil}), do: values
  defp maybe_add_metadata(values, %{metadata: metadata}), do: Map.put(values, :m, metadata)
end
