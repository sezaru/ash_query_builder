# AshQueryBuilder

**A simple query builder helper for Ash.Query**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ash_query_builder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ash_query_builder, "~> 0.4.0"}
  ]
end
```
## Usage

`AshQueryBuilder` is a helper to make it easy to serialize/deserialize URL queries into a structure that can be used to generate a `Ash.Query` with filters and sorting. This is mainly useful when you need to create tables that can be sorted or filtered.

Example:

``` elixir
alias Plug.Conn.Query

# We first create our builder struct
builder = AshQueryBuilder.new()

# Now we can add multiple types of filters to it.
{builder, filter_1} = AshQueryBuilder.add_filter(builder, :updated_at, :<, DateTime.utc_now(), id: "my_custom_id")
{builder, filter_2} = AshQueryBuilder.add_filter(builder, :first_name, "in", ["blibs", "blobs"], [])
{builder, _} = AshQueryBuilder.add_filter(builder, [:organization], :name, :ilike, "MyOrg", enabled?: false)
{builder, _} = AshQueryBuilder.add_filter(builder, :created_by, :is_nil, nil, [])
{builder, _} = AshQueryBuilder.add_filter(builder, :surname, :left_word_similarity, "blobs", [])

# We can also add sorting rules
{builder, sorter_1} = AshQueryBuilder.add_sorter(builder, :updated_at, :desc)
{builder, sorter_2} = AshQueryBuilder.add_sorter(builder, :first_name, :asc)

# This will generate a map that can be stored into a URL query parameters
query_params = AshQueryBuilder.to_params(builder, with_disabled?: true)

# This will generate the URL query parameters, it is similar to just calling ~p"my_url?#{query_params}"
url_query_params = Query.encode(query_params)

# Now we can decode the query back and parse it into a new builder
builder = url_query_params |> Query.decode |> AshQueryBuilder.parse()

# Finally we can use the builder to create the actual Ash.Query
query = Ash.Query.new(Example.MyApi.User)

query = AshQueryBuilder.to_query(builder, query)

# And run the query
Example.MyApi.read!(query)

# We can also remove filters and sorters by id
builder = AshQueryBuilder.remove_filter(builder, filter_1.id)
builder = AshQueryBuilder.remove_sorter(builder, sorter_1.id)

# And replace existing ones
{:error, :not_found} = AshQueryBuilder.replace_filter(builder, filter_1.id, :updated_at, :<, DateTime.utc_now(), [])
{:ok, builder} = AshQueryBuilder.replace_filter(builder, filter_2.id, :first_name, :in, ["blibs", "blubs"], [])

{:error, :not_found} = AshQueryBuilder.replace_sorter(builder, sorter_1.id, :updated_at, :asc, [])
{:ok, builder} = AshQueryBuilder.replace_sorter(builder, filter_2.id, :first_name, :desc, [])
```

## Expanding

`AshQueryBuilder` comes already with a lot of filters commonly used in PostgreSQL (you can find all of them in the `lib/ash_query_builder/filter` directory).

If you need some other specific filter that the library don't support out of the box, you can just easily create it. For example, let's say you are using `postgis` and want to filter by radius, you can create a filter for it like this:

``` elixir
defmodule MyFilter do
  @moduledoc false

  use AshQueryBuilder.Filter, operator: :by_radius

  @impl true
  def new(id, path, field, value, opts) do
    enabled? = Keyword.get(opts, :enabled?, true)

    struct(__MODULE__, id: id, field: field, path: path, value: value, enabled?: enabled?)
  end
end

defimpl AshQueryBuilder.Filter.Protocol, for: MyFilter do
  use AshQueryBuilder.Filter.QueryHelpers

  def to_filter(filter, query) do
    {longitude, latitude, distance_in_meters} = filter.value

    Ash.Query.filter(
      query,
      expr(
        fragment(
          "ST_DWithin(?, ST_POINT(?, ?)::geography, ?)",
          ^make_ref(filter),
          ^longitude,
          ^latitude,
          ^distance_in_meters
        )
      )
    )
  end

  def operator(_), do: MyFilter.operator()
end
```

And then you can use it like this:

``` elixir
builder = AshQueryBuilder.add_filter(builder, :geometry, :by_radius, {-86.79, 36.17, 1000})
```
