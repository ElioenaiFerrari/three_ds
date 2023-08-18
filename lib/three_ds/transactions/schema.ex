defmodule ThreeDs.Transactions.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  alias ThreeDs.Types.Encrypted

  @uuid_regex ~r/^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$/i
  @valid_indicators ~w(approved refused not_performed)
  @valid_device_channels ~w(app browser three_ds_requestor)
  @valid_protocol_versions ~w(2.1.0 2.2.0)
  @valid_authentication_types ~w(static dynamic oob decoupled)
  @account_number_regex ~r/^\d{13,19}$/

  @primary_key {:server_id, :string, autogenerate: false}
  @derive {Poison.Encoder, except: [:__meta__, :__struct__, :authentication_value]}
  schema "transactions" do
    field(:account_number, :string)
    field(:acs_id, :string)
    field(:acs_url, :string, virtual: true)
    field(:ds_id, :string)
    field(:stone_id, :string)
    field(:authentication_type, :string)
    field(:authentication_value, Encrypted)
    field(:challenge_indicator, :string)
    field(:device_channel, :string)
    field(:fingerprint_indicator, :string)
    field(:fingerprint_url, :string, virtual: true)
    field(:protocol_version, :string)
    field(:status, :string)

    timestamps()
  end

  def changeset(transaction, attrs \\ %{}) do
    transaction
    |> cast(attrs, [
      :account_number,
      :server_id,
      :acs_id,
      :acs_url,
      :ds_id,
      :authentication_value,
      :authentication_type,
      :challenge_indicator,
      :device_channel,
      :fingerprint_indicator,
      :fingerprint_url,
      :stone_id,
      :protocol_version,
      :status
    ])
    |> validate_required([:account_number, :server_id, :protocol_version])
    |> validate_format(:server_id, @uuid_regex, message: "is not a valid UUID")
    |> validate_format(:acs_id, @uuid_regex, message: "is not a valid UUID")
    |> validate_format(:stone_id, @uuid_regex, message: "is not a valid UUID")
    |> validate_inclusion(:challenge_indicator, @valid_indicators)
    |> validate_inclusion(:fingerprint_indicator, @valid_indicators)
    |> validate_inclusion(:status, @valid_indicators)
    |> validate_format(:account_number, @account_number_regex)
    |> validate_inclusion(:device_channel, @valid_device_channels)
    |> validate_inclusion(:protocol_version, @valid_protocol_versions)
    |> validate_inclusion(:authentication_type, @valid_authentication_types)
    |> mask_account_number()
  end

  defp mask_account_number(
         %Ecto.Changeset{valid?: true, changes: %{account_number: account_number}} = changeset
       ) do
    visible_prefix = String.slice(account_number, 0..3)
    visible_suffix = String.slice(account_number, -4..-1)
    masked_middle = String.duplicate("*", byte_size(account_number) - 8)
    masked_account_number = visible_prefix <> masked_middle <> visible_suffix
    put_change(changeset, :account_number, masked_account_number)
  end

  defp mask_account_number(changeset), do: changeset
end
