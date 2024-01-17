defmodule AshQueryBuilder.Sorter do
  @moduledoc false

  @type t :: %__MODULE__{
          id: non_neg_integer,
          field: atom,
          order: :asc | :asc_nils_last | :desc | :desc_nils_last
        }

  defstruct [:id, :field, :order]

  def new(id \\ :erlang.unique_integer([:monotonic, :positive]), field, order) do
    true = order in [:desc, :desc_nils_last, :asc, :asc_nils_last]

    struct!(__MODULE__, id: id, field: field, order: order)
  end
end
