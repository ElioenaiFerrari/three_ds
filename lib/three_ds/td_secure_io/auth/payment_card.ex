defmodule ThreeDs.TdSecureIo.Auth.PaymentCard do
  use Ecto.Schema
  import Ecto.Changeset
  @valid_types ~w(credit debit)
  @valid_brands ~w(visa master maestro elo american_express diners_club hiper hiper_card discover jcb)

  embedded_schema do
    field(:brand, :string)
    field(:expiry_date, :string)
    field(:type, :string)
    field(:holder, :string)
  end

  def changeset(payment_card, attrs \\ %{}) do
    payment_card
    |> cast(attrs, [
      :brand,
      :expiry_date,
      :type,
      :holder
    ])
    |> validate_required([:brand, :holder, :expiry_date, :type])
    |> validate_format(:expiry_date, ~r/\d{2}\/\d{2}/, message: "must be in the format MM/YY")
    |> validate_inclusion(:brand, @valid_brands)
    |> validate_inclusion(:type, @valid_types)
    |> validate_expiry_date()
  end

  defp validate_expiry_date(changeset) do
    [month, year] =
      changeset
      |> get_change(:expiry_date)
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)

    expiration = NaiveDateTime.new!(year + 2000, month, 1, 0, 0, 0)
    today = NaiveDateTime.utc_now()

    case NaiveDateTime.compare(expiration, today) do
      :lt -> add_error(changeset, :expiry_date, "expiry date has passed")
      _ -> changeset
    end
  end
end
