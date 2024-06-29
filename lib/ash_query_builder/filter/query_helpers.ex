defmodule AshQueryBuilder.Filter.QueryHelpers do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import Ash.Query
      import Ash.Expr

      def make_ref(filter), do: ref(filter.path, filter.field)
    end
  end
end
