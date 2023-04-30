defmodule ThreeDs.TdSecureIo.PostAuth.Response do
  defstruct [
    :acs_id,
    :authentication_type,
    :authentication_value,
    :ds_id,
    :server_id,
    :status,
    :challenge_indicator
  ]

  @mapped_indicator %{
    "N" => "refused",
    "Y" => "done",
    "U" => "not_performed"
  }

  @mapped_authentication_types %{
    "01" => "static",
    "02" => "dynamic",
    "03" => "oob",
    "04" => "decoupled"
  }

  def parse(response) do
    %__MODULE__{
      acs_id: response["acsTransID"],
      authentication_type:
        Map.fetch!(@mapped_authentication_types, response["authenticationType"]),
      authentication_value: response["authenticationValue"],
      ds_id: response["dsTransID"],
      server_id: response["threeDSServerTransID"],
      status: Map.fetch!(@mapped_indicator, response["transStatus"]),
      challenge_indicator: Map.fetch!(@mapped_indicator, response["transStatus"])
    }
  end
end
