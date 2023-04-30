defmodule ThreeDs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ThreeDs.Repo,
      {Plug.Cowboy, plug: ThreeDsWeb.Endpoint, scheme: :http, options: [port: 4000]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ThreeDs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
