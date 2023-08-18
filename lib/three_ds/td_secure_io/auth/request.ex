defmodule ThreeDs.TdSecureIo.Auth.Request do
  use Ecto.Schema
  import Ecto.Changeset
  alias ThreeDs.TdSecureIo.Auth.{Address, Phone, Purchase, Browser, PaymentCard}

  @account_number_regex ~r/^\d{13,19}$/
  @valid_account_types ~w(not_applicable credit debit)
  @valid_transaction_types ~w(purchase_service check_acceptance account_funding quasi_cash prepaid_activation)
  @valid_indicators ~w(approved refused not_performed)

  @mapped_device_channels %{
    "app" => "01",
    "browser" => "02",
    "three_ds_requestor" => "03"
  }

  @mapped_indicators %{
    "approved" => "Y",
    "refused" => "N",
    "not_performed" => "U"
  }

  @primary_key false
  @derive {Poison.Encoder, [except: [:__meta__, :__struct__]]}
  embedded_schema do
    field(:account_number, :string)
    field(:account_type, :string)
    field(:address_match, :string)
    field(:email, :string)
    field(:device_channel, :string)
    field(:message_type, :string)
    field(:challenge_cycle_indicator, :string)
    field(:requestor_url, :string)
    field(:transaction_server_id, :string)
    field(:transaction_type, :string)
    embeds_one(:payment_card, PaymentCard)
    embeds_one(:billing_address, Address)
    embeds_one(:shipping_address, Address)
    embeds_one(:browser, Browser)
    embeds_one(:purchase, Purchase)
    embeds_many(:phones, Phone)
  end

  def changeset(request, attrs \\ %{}) do
    request
    |> cast(attrs, [
      :account_number,
      :account_type,
      :address_match,
      :email,
      :device_channel,
      :challenge_cycle_indicator,
      :requestor_url,
      :transaction_server_id,
      :transaction_type
    ])
    |> validate_required([
      :account_number,
      :account_type,
      :address_match,
      :email,
      :device_channel,
      :challenge_cycle_indicator,
      :requestor_url,
      :transaction_server_id,
      :transaction_type
    ])
    |> validate_format(:account_number, @account_number_regex)
    |> validate_inclusion(:account_type, @valid_account_types)
    |> validate_inclusion(:transaction_type, @valid_transaction_types)
    |> validate_inclusion(:challenge_cycle_indicator, @valid_indicators)
    |> cast_embed(:payment_card, required: true, with: &PaymentCard.changeset/2)
    |> cast_embed(:billing_address, required: true, with: &Address.changeset/2)
    |> cast_embed(:shipping_address, required: true, with: &Address.changeset/2)
    |> cast_embed(:browser, required: true, with: &Browser.changeset/2)
    |> cast_embed(:purchase, required: true, with: &Purchase.changeset/2)
    |> cast_embed(:phones, required: true, with: &Phone.changeset/2)
  end

  def encode(%Ecto.Changeset{valid?: true, changes: request}) do
    browser = request.browser.changes

    %{
      "acctNumber" => request.account_number,
      "messageType" => "AReq",
      "deviceChannel" => Map.fetch!(@mapped_device_channels, request.device_channel),
      "messageCategory" => "02",
      "messageVersion" => "2.2.0",
      "threeDSServerTransID" => request.transaction_server_id,
      "notificationURL" => "http://localhost:4000/api/post_auth",
      "browserAcceptHeader" => browser.accept_header,
      "browserJavascriptEnabled" => browser.javascript_enabled,
      "browserJavaEnabled" => false,
      "browserScreenHeight" => Integer.to_string(browser.screen_height),
      "browserScreenWidth" => Integer.to_string(browser.screen_width),
      "browserLanguage" => browser.language,
      "browserTZ" => Integer.to_string(browser.tz),
      "browserColorDepth" => Integer.to_string(1),
      "threeDSRequestorURL" => request.requestor_url,
      "browserUserAgent" => browser.user_agent,
      "threeDSRequestorAuthenticationInd" => "01",
      "threeDSCompInd" => Map.fetch!(@mapped_indicators, request.challenge_cycle_indicator)
    }
    |> Poison.encode()
  end
end
