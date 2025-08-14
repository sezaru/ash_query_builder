defmodule AshQueryBuilder.Filter.QueryHelpers do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import Ash.Query
      import Ash.Expr

      def make_ref(%{field: field} = filter) when is_atom(field),
        do: expr(^ref(filter.path, filter.field))

      def make_ref(%{field: fields} = filter) when is_list(fields) do
        case filter.path do
          [field] ->
            expr(get_path(^ref(field), fields))

          [_, _ | _] = path ->
            {path, [field]} = Enum.split(path, -1)

            expr(get_path(^ref(path, field), fields))
        end
      end
    end
  end
end
