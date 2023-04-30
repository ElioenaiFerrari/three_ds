defmodule ThreeDs.TdSecureIo.Auth.Phone do
  use Ecto.Schema
  import Ecto.Changeset
  @valid_country_codes ~w(55)
  @valid_types ~w(personal work)

  embedded_schema do
    field(:country_code, :string)
    field(:subscriber, :string)
    field(:type, :string)
  end

  def changeset(phone, attrs \\ %{}) do
    phone
    |> cast(attrs, [
      :country_code,
      :subscriber,
      :type
    ])
    |> validate_required([
      :country_code,
      :subscriber,
      :type
    ])
    |> validate_inclusion(:country_code, @valid_country_codes)
    |> validate_inclusion(:type, @valid_types)
  end
end
