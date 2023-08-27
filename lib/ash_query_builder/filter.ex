defmodule AshQueryBuilder.Filter do
  @moduledoc false

  alias AshQueryBuilder.Filter.Protocol

  use Memoize

  @callback operator :: atom

  @callback new(non_neg_integer | String.t(), [atom], atom, any, Keyword.t()) ::
              Protocol.t()

  defmacro __using__(operator: operator) do
    quote do
      @type t :: %__MODULE__{
              id: non_neg_integer | String.t(),
              field: atom,
              path: [atom],
              value: any,
              enabled?: boolean,
              metadata: map | nil
            }

      defstruct [:id, :field, :path, :value, :enabled?, :metadata]

      @behaviour AshQueryBuilder.Filter

      @impl true
      def operator, do: unquote(operator)
    end
  end

  def new(field, operator, value, opts), do: new([], field, operator, value, opts)

  def new(path, field, operator, value, opts) do
    id = Keyword.get(opts, :id, :erlang.unique_integer([:monotonic, :positive]))

    new(id, path, field, operator, value, opts)
  end

  def new(id, path, field, operator, value, opts),
    do: filter_module!(operator).new(id, path, field, value, opts)

  defp filter_module!(operator) when is_atom(operator),
    do: Map.fetch!(filters(), operator)

  defmemop filters, permanent: true do
    {_, modules} = Protocol.__protocol__(:impls)

    Enum.reduce(modules, %{}, fn module, acc ->
      Map.put(acc, apply(module, :operator, []), module)
    end)
  end
end
