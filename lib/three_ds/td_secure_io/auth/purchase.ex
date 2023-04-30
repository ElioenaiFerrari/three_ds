defmodule ThreeDs.TdSecureIo.Auth.Purchase do
  use Ecto.Schema
  import Ecto.Changeset
  @valid_currencies ~w(BRL)

  embedded_schema do
    field(:amount, :integer)
    field(:currency, :string)
    field(:date, :utc_datetime)
    field(:installments, :integer)
  end

  def changeset(purchase, attrs \\ %{}) do
    purchase
    |> cast(attrs, [
      :amount,
      :currency,
      :date,
      :installments
    ])
    |> validate_required([
      :amount,
      :currency,
      :date,
      :installments
    ])
    |> validate_number(:amount, greater_than: 0)
    |> validate_inclusion(:currency, @valid_currencies)
  end
end
