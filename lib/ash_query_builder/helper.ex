defmodule AshQueryBuilder.Helper do
  @moduledoc false

  alias AshQueryBuilder.FilterScope

  def add_argument(%{arguments: arguments} = struct, argument),
    do: %{struct | arguments: [argument] ++ arguments}

  def replace_argument(%{arguments: arguments} = struct, argument) do
    with {:ok, arguments} <-
           find_and_update(arguments, &(&1.name == argument.name), fn _ -> argument end) do
      {:ok, %{struct | arguments: arguments}}
    end
  end

  def add_or_replace_argument(struct, argument) do
    case replace_argument(struct, argument) do
      {:error, :not_found} -> add_argument(struct, argument)
      {:ok, struct} -> struct
    end
  end

  def find_argument(%{arguments: arguments}, name) do
    Enum.find(arguments, fn argument -> argument.name == name end)
  end

  def remove_argument(struct, name) do
    arguments = Enum.reject(struct.arguments, fn argument -> argument.name == name end)

    %{struct | arguments: arguments}
  end

  def reset_arguments(struct), do: %{struct | arguments: []}

  def add_filter(%{filters: filters} = struct, filter),
    do: %{struct | filters: [filter] ++ filters}

  def replace_filter(%{filters: filters} = struct, filter) do
    with {:ok, filters} <- find_and_update(filters, &(&1.id == filter.id), fn _ -> filter end) do
      {:ok, %{struct | filters: filters}}
    end
  end

  def add_or_replace_filter(struct, filter) do
    case replace_filter(struct, filter) do
      {:error, :not_found} -> add_filter(struct, filter)
      {:ok, struct} -> struct
    end
  end

  def find_filter(%{filters: filters}, id, opts \\ []) do
    only_enabled? = Keyword.get(opts, :only_enabled?, false)

    Enum.find(filters, fn
      %FilterScope{} = scope ->
        scope.id == id

      filter ->
        if only_enabled? do
          filter.id == id and filter.enabled?
        else
          filter.id == id
        end
    end)
  end

  def remove_filter(struct, id) do
    filters = Enum.reject(struct.filters, fn filter -> filter.id == id end)

    %{struct | filters: filters}
  end

  def reset_filters(struct), do: %{struct | filters: []}

  defp find_and_update(list, find_fn, update_fn) do
    case Enum.find_index(list, find_fn) do
      nil -> {:error, :not_found}
      index -> {:ok, List.update_at(list, index, update_fn)}
    end
  end
end
