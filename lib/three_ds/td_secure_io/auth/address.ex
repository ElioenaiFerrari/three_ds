defmodule ThreeDs.TdSecureIo.Auth.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_countries ~w(BRA)

  embedded_schema do
    field(:street, :string)
    field(:number, :string)
    field(:county, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string, default: "BRA")
    field(:zip_code, :string)
  end

  def changeset(address, attrs \\ %{}) do
    address
    |> cast(attrs, [
      :street,
      :number,
      :county,
      :city,
      :state,
      :country,
      :zip_code
    ])
    |> validate_required([
      :street,
      :number,
      :county,
      :city,
      :state,
      :country,
      :zip_code
    ])
    |> validate_inclusion(:country, @valid_countries)
    |> validate_format(:zip_code, ~r/^\d{8}$/, message: "invalid CEP format")
  end
end
