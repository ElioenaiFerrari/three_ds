defmodule ThreeDs.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add(:server_id, :string, primary_key: true)

      add(:acs_id, :string)
      add(:ds_id, :string)
      add(:stone_id, :string)
      add(:authentication_type, :string)
      add(:authentication_value, :string)
      add(:challenge_indicator, :string)
      add(:device_channel, :string)
      add(:fingerprint_indicator, :string)
      add(:protocol_version, :string)
      add(:status, :string)

      timestamps()
    end
  end
end
