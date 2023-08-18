defmodule ThreeDs.TdSecureIo.Api do
  use Tesla
  require OpenTelemetry.Tracer
  alias OpenTelemetry.Tracer
  alias ThreeDs.TdSecureIo.{PreAuth, Auth, PostAuth}
  @api_key Application.compile_env!(:three_ds, :tds_provider_api_key)
  @base_url Application.compile_env!(:three_ds, :tds_provider_base_url)

  @mapped_indicators %{
    "Y" => "approved",
    "N" => "refused",
    "U" => "not_performed"
  }

  plug(Tesla.Middleware.BaseUrl, @base_url)
  # plug(Tesla.Middleware.OpenTelemetry)

  plug(Tesla.Middleware.Headers, [
    {"APIKey", @api_key},
    {"content-type", "application/json; charset=utf-8"}
  ])

  plug(Tesla.Middleware.JSON, engine: Poison)

  defp handle_response(%{"messageType" => "Erro"} = error) do
    {:error, %{message: "#{error["errorDescription"]}: #{error["errorDetail"]}"}}
  end

  defp handle_response(%{"messageType" => "CRD"} = response) do
    {:ok, PreAuth.Response.parse(response)}
  end

  defp handle_response(%{"messageType" => "ARes"} = response) do
    {:ok, Auth.Response.parse(response)}
  end

  defp handle_response(%{"messageType" => "RReq"} = response) do
    {:ok, PostAuth.Response.parse(response)}
  end

  def pre_auth(attrs \\ %{}) do
    Tracer.with_span "pre_auth.provider" do
      with %Ecto.Changeset{valid?: true} = request <-
             PreAuth.Request.changeset(
               %PreAuth.Request{},
               attrs
             ),
           _ <- Tracer.add_event("validate changeset", request),
           {:ok, request_json} <- PreAuth.Request.encode(request),
           _ <- Tracer.add_event("encoding request", request_json) do
        post!("/preauth", request_json, headers: [])
        |> Map.fetch!(:body)
        |> handle_response()
      end
    end
  end

  def auth(attrs \\ %{}) do
    with %Ecto.Changeset{valid?: true} = request <-
           Auth.Request.changeset(
             %Auth.Request{},
             attrs
           ),
         {:ok, request_json} <- Auth.Request.encode(request) do
      post!("/auth", request_json, headers: [])
      |> Map.fetch!(:body)
      |> handle_response()
    end
  end

  def post_auth(attrs \\ %{}) do
    with %Ecto.Changeset{valid?: true} = request <-
           PostAuth.Request.changeset(
             %PostAuth.Request{},
             %{
               acs_id: attrs["acsTransID"],
               challenge_indicator:
                 Map.fetch!(@mapped_indicators, attrs["challengeCompletionInd"]),
               protocol_version: attrs["messageVersion"],
               transaction_server_id: attrs["threeDSServerTransID"],
               transaction_status: attrs["transStatus"]
             }
           ),
         {:ok, request_json} <- PostAuth.Request.encode(request) do
      post!("/postauth", request_json, headers: [])
      |> Map.fetch!(:body)
      |> handle_response()
    end
  end
end
