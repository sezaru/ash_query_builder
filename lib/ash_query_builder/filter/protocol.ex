defprotocol AshQueryBuilder.Filter.Protocol do
  @spec to_filter(t, Ash.Query.t()) :: Ash.Query.t()
  def to_filter(filter, query)

  @spec operator(t) :: atom
  def operator(filter)
end
