defmodule AshQueryBuilder.FilterScope do
  @moduledoc false

  alias AshQueryBuilder.Helper

  defstruct [:id, :operation, filters: []]

  def new(operation, opts \\ []) when operation in [:and, :or] do
    id = Keyword.get(opts, :id, :erlang.unique_integer([:monotonic, :positive]))

    struct!(__MODULE__, %{id: id, operation: operation})
  end

  defdelegate add_filter(scope, filter), to: Helper

  defdelegate replace_filter(scope, filter), to: Helper

  defdelegate add_or_replace_filter(scope, filter), to: Helper

  defdelegate find_filter(builder, id, opts \\ []), to: Helper

  defdelegate remove_filter(builder, id), to: Helper

  defdelegate reset_filters(builder), to: Helper
end
