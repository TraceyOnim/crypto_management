defmodule Transaction.Cache do
  use Nebulex.Cache,
    otp_app: :crypto_management,
    adapter: Nebulex.Adapters.Local
end
