defprotocol AshQueryBuilder.Filter.Protocol do
  @spec to_expression(t) :: Ash.Filter.t()
  def to_expression(filter)

  @spec operator(t) :: atom
  def operator(filter)
end
