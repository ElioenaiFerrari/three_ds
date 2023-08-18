defmodule ThreeDs.MixProject do
  use Mix.Project

  def project do
    [
      app: :three_ds,
      version: "0.1.0",
      elixir: "~> 1.15-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger,
        :ecto,
        :ecto_sqlite3,
        :comeonin,
        :poison,
        :tesla,
        :plug_cowboy,
        :cors_plug
      ],
      mod: {ThreeDs.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.10"},
      {:ecto_sqlite3, "~> 0.10.0"},
      {:credo, "~> 1.7"},
      {:comeonin, "~> 5.3"},
      {:poison, "~> 5.0"},
      {:tesla, "~> 1.6"},
      {:plug_cowboy, "~> 2.6"},
      {:cors_plug, "~> 3.0"},
      {:opentelemetry, "~> 1.3"},
      {:opentelemetry_api, "~> 1.2"},
      {:opentelemetry_exporter, "~> 1.6"}
      # {:opentelemetry_cowboy, "~> 0.2"},
      # {:opentelemetry_tesla, "~> 2.2"}
    ]
  end
end
