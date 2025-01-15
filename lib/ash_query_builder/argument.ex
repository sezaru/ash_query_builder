defmodule AshQueryBuilder.Argument do
  @moduledoc false

  @type t :: %__MODULE__{name: atom | String.t(), value: any, metadata: map | nil}

  defstruct [:name, :value, :metadata]

  def new(name, value, opts \\ []) do
    metadata = Keyword.get(opts, :metadata)

    struct!(__MODULE__, name: name, value: value, metadata: metadata)
  end
end
