defmodule ThreeDs.TdSecureIo.PreAuth.Response do
  defstruct [
    :fingerprint_url,
    :protocol_version,
    :server_id
  ]

  def parse(response) do
    %__MODULE__{
      fingerprint_url: response["threeDSMethodURL"],
      protocol_version: response["dsEndProtocolVersion"],
      server_id: response["threeDSServerTransID"]
    }
  end
end
