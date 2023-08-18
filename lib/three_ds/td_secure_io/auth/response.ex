defmodule ThreeDs.TdSecureIo.Auth.Response do
  defstruct [
    :challenge_indicator,
    :acs_url,
    :acs_id,
    :ds_id,
    :server_id
  ]

  @mapped_challenge_indicator %{
    "N" => "refused",
    "Y" => "approved",
    "U" => "not_performed"
  }

  def parse(response) do
    %__MODULE__{
      acs_id: response["acsTransID"],
      acs_url: response["acsURL"],
      ds_id: response["dsTransID"],
      challenge_indicator:
        Map.fetch!(@mapped_challenge_indicator, response["acsChallengeMandated"]),
      server_id: response["threeDSServerTransID"]
    }
  end
end
