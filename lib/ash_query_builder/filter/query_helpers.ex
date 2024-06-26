defmodule AshQueryBuilder.Filter.QueryHelpers do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import Ash.Query
      import Ash.Expr, only: [expr: 1]

      defmacro make_ref(filter) do
        quote do
          expr(^ref(unquote(filter).field, unquote(filter).path))
        end
      end
    end
  end
end
