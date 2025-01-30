defmodule AshQueryBuilder.Sorter do
  @moduledoc false

  @type order :: :asc | :asc_nils_last | :desc | :desc_nils_last

  @type t :: %__MODULE__{
          id: non_neg_integer,
          field: atom,
          order: order | {map, order}
        }

  defstruct [:id, :field, :order]

  def new(id \\ :erlang.unique_integer([:monotonic, :positive]), field, order) do
    validate_order!(order)

    struct!(__MODULE__, id: id, field: field, order: order)
  end

  defp validate_order!(order) when is_atom(order) do
    true = order in [:desc, :desc_nils_last, :asc, :asc_nils_last]
  end

  defp validate_order!({_, order}), do: validate_order!(order)
end
