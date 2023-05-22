defmodule AshQueryBuilder.Filter do
  @moduledoc false

  alias AshQueryBuilder.Filter.Protocol

  use Memoize

  @callback operator :: atom

  @callback new(non_neg_integer, [atom], atom, any) :: Protocol.t()

  defmacro __using__(operator: operator) do
    quote do
      @type t :: %__MODULE__{id: non_neg_integer, field: atom, path: [atom], value: any}

      defstruct [:id, :field, :path, :value]

      import Ash.Query

      @behaviour AshQueryBuilder.Filter

      @impl true
      def operator, do: unquote(operator)
    end
  end

  def new(field, operator, value), do: new([], field, operator, value)

  def new(id \\ :erlang.unique_integer([:monotonic, :positive]), path, field, operator, value) do
    filter_module!(operator).new(id, path, field, value)
  end

  def filter_module!(operator) when is_atom(operator),
    do: Map.fetch!(filters(), operator)

  defmemop filters, permanent: true do
    {_, modules} = Protocol.__protocol__(:impls)

    Enum.reduce(modules, %{}, fn module, acc ->
      Map.put(acc, apply(module, :operator, []), module)
    end)
  end
end
