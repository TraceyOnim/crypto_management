defmodule CryptoManagement.Repo do
  use Ecto.Repo,
    otp_app: :crypto_management,
    adapter: Ecto.Adapters.Postgres
end
