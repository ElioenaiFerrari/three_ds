defmodule ThreeDs.Repo do
  use Ecto.Repo,
    otp_app: :three_ds,
    adapter: Ecto.Adapters.SQLite3
end
