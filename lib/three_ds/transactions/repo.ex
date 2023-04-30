defmodule ThreeDs.Transactions.Repo do
  alias ThreeDs.Transactions.Schema
  import Ecto.Query

  def create(attrs \\ %{}) do
    %Schema{}
    |> Schema.changeset(attrs)
    |> ThreeDs.Repo.insert()
  end

  def update(server_id, attrs \\ %{}) do
    Schema
    |> ThreeDs.Repo.get(server_id)
    |> Schema.changeset(attrs)
    |> ThreeDs.Repo.update()
  end

  def all(), do: ThreeDs.Repo.all(Schema)

  def last_transactions() do
    from(Schema,
      order_by: [desc: :inserted_at],
      limit: 10
    )
    |> ThreeDs.Repo.all()
  end

  def get(server_id), do: ThreeDs.Repo.get(Schema, server_id)
end
