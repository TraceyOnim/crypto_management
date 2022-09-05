ExUnit.start()
Mox.defmock(CryptoManagement.HttpClientMock, for: CryptoManagement.ClientBehaviour)
Ecto.Adapters.SQL.Sandbox.mode(CryptoManagement.Repo, :manual)
