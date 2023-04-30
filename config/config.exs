import Config

config :three_ds, ThreeDs.Repo, database: "database.db"

config :three_ds,
  ecto_repos: [ThreeDs.Repo],
  secret_key: System.get_env("SECRET_KEY"),
  tds_provider_api_key: System.get_env("TDS_PROVIDER_API_KEY"),
  tds_provider_base_url: System.get_env("TDS_PROVIDER_BASE_URL")
