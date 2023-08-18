defmodule ThreeDs.TdSecureIo.PostAuth.Request do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_indicators ~w(approved refused not_performed)
  # @mapped_indicators %{
  #   "approved" => "Y",
  #   "refused" => "N",
  #   "not_performed" => "U"
  # }

  @primary_key false
  @derive {Poison.Encoder, [except: [:__meta__, :__struct__]]}
  embedded_schema do
    field(:acs_id, :string)
    field(:challenge_indicator, :string)
    field(:transaction_server_id, :string)
    field(:transaction_status, :string)
  end

  def changeset(request, attrs \\ %{}) do
    request
    |> cast(attrs, [
      :acs_id,
      :challenge_indicator,
      :transaction_server_id,
      :transaction_status
    ])
    |> validate_required([
      :acs_id,
      :challenge_indicator,
      :transaction_server_id,
      :transaction_status
    ])
    |> validate_inclusion(:challenge_indicator, @valid_indicators)
  end

  def encode(%Ecto.Changeset{valid?: true, changes: request}) do
    %{
      "threeDSServerTransID" => request.transaction_server_id
    }
    |> Poison.encode()
  end
end
