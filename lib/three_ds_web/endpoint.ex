defmodule ThreeDsWeb.Endpoint do
  use Plug.Router
  import Plug.Conn
  import Ecto.Changeset, only: [traverse_errors: 2]

  plug(:match)
  plug(CORSPlug)
  plug(Plug.Logger)
  # plug(Plug.Telemetry, event_prefix: [:three_ds])
  plug(Plug.Parsers, parsers: [{:json, json_encoder: Poison, json_decoder: Poison}, :urlencoded])
  plug(:dispatch)

  require OpenTelemetry.Tracer
  alias OpenTelemetry.Tracer
  alias ThreeDs.TdSecureIo.{Api, Fingerprint}
  alias ThreeDs.Transactions

  defp fallback(conn, %Ecto.Changeset{valid?: false} = error) do
    Tracer.set_status(:error)

    Tracer.with_span "fallback" do
      errors =
        traverse_errors(error, fn {msg, opts} ->
          Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
            opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
          end)
        end)

      Tracer.add_event("error", errors)

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:bad_request, Poison.encode!(%{errors: errors}))
    end
  end

  post "/api/pre_auth" do
    Tracer.with_span "pre_auth.endpoint" do
      with {:ok, response} <- Api.pre_auth(conn.params),
           _ <- Tracer.add_event("received response from provider", response),
           {:ok, transaction} <-
             response
             |> Map.from_struct()
             |> Map.put(:account_number, conn.params["account_number"])
             |> Transactions.Repo.create(),
           _ <- Tracer.add_event("transaction created", response) do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:created, Poison.encode!(transaction))
      else
        error -> fallback(conn, error)
      end
    end
  end

  post "/api/auth" do
    Tracer.with_span "auth.endpoint" do
      with {:ok, response} <- Api.auth(conn.params),
           _ <- Tracer.add_event("received response from provider", response),
           {:ok, transaction} <-
             Transactions.Repo.update(response.server_id, Map.from_struct(response)),
           _ <- Tracer.add_event("transaction updated", transaction) do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:ok, Poison.encode!(transaction))
      else
        error -> fallback(conn, error)
      end
    end
  end

  post "/api/post_auth" do
    Tracer.with_span "post_auth.endpoint" do
      params =
        conn
        |> Map.fetch!(:params)
        |> Fingerprint.decode(:challenge)

      with {:ok, response} <- Api.post_auth(params),
           _ <- Tracer.add_event("received response from provider", response),
           {:ok, transaction} <-
             Transactions.Repo.update(response.server_id, Map.from_struct(response)),
           _ <- Tracer.add_event("transaction updated", transaction) do
        payload = %{
          event_type: "challenge_done",
          data: transaction,
          error: nil
        }

        conn
        |> put_resp_content_type("text/html")
        |> send_resp(
          :ok,
          "<script> window.parent.postMessage(#{Poison.encode!(payload)}, '*') </script>"
        )
      else
        error -> fallback(conn, error)
      end
    end
  end

  post "/api/fingerprint" do
    transaction_server_id =
      conn
      |> Map.fetch!(:params)
      |> Fingerprint.decode(:method)
      |> Map.fetch!("threeDSServerTransID")

    with {:ok, transaction} <-
           Transactions.Repo.update(
             transaction_server_id,
             %{fingerprint_indicator: "approved"}
           ) do
      payload = %{
        event_type: "fingerprint_done",
        data: transaction,
        error: nil
      }

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(
        :ok,
        "<script> window.parent.postMessage(#{Poison.encode!(payload)}, '*') </script>"
      )
    end
  end

  # código da rota /transactions
  get "/api/transactions/last" do
    transactions = Transactions.Repo.last_transactions()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, Poison.encode!(transactions))
  end

  # código da rota /transactions/:id
  get "/api/transactions/:server_id" do
    transaction =
      conn
      |> Map.fetch!(:params)
      |> Map.fetch!("server_id")
      |> Transactions.Repo.get()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, Poison.encode!(transaction))
  end

  match _ do
    send_resp(conn, :not_found, "")
  end
end
