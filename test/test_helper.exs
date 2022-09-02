ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(CryptoManagement.Repo, :manual)
Mox.defmock(CryptoManagement.HttpClientMock, for: CryptoManagement.ClientBehaviour)
