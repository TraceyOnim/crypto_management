import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :crypto_management, CryptoManagement.Repo,
  username: "postgres",
  password: "postgres",
  database: "crypto_management_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :crypto_management, CryptoManagementWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "LNdm5XCbh7dojvazrB//4CktDWsu3NBrv0NHuUrJVDhBsl7gA+Q/aobuSqVx+Q8V",
  server: false

# In test we don't send emails.
config :crypto_management, CryptoManagement.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :crypto_management, :http_client, CryptoManagement.HttpClientMock
