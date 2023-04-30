defmodule ThreeDs.TdSecureIo.PreAuth.Request do
  use Ecto.Schema
  import Ecto.Changeset
  @account_number_regex ~r/^\d{13,19}$/
  # @valid_directory_servers ~w(standin visa mastercard jcb amex protectbuy sbn)

  @primary_key false
  @derive {Poison.Encoder, [except: [:__meta__, :__struct__]]}
  embedded_schema do
    field(:account_number, :string)
  end

  def changeset(request, attrs \\ %{}) do
    request
    |> cast(attrs, [
      :account_number
    ])
    |> validate_required([:account_number])
    |> validate_format(:account_number, @account_number_regex)
  end

  def encode(%Ecto.Changeset{valid?: true, changes: changes}) do
    %{
      "acctNumber" => changes.account_number
    }
    |> Poison.encode()
  end

  def encode(changeset), do: {:error, changeset}
end
