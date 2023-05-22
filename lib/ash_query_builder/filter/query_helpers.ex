defmodule AshQueryBuilder.Filter.QueryHelpers do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import Ash.Query

      defmacro make_ref(filter) do
        quote do
          require Ash.Expr

          Ash.Expr.expr(ref(^unquote(filter).field, ^unquote(filter).path))
        end
      end
    end
  end
end
