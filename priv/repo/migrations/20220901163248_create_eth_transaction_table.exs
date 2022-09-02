defmodule CryptoManagement.Repo.Migrations.CreateEthTransactionTable do
  use Ecto.Migration

  def change do
   create table(:transactions, primary_key: false) do
      add :hash, :string, primary_key: true
      add :block_hash, :string
      add :block_number, :integer
      add :chain_id, :string
      add :from, :string
      add :gas, :string
      add :gas_price, :string
      add :input, :string
      add :max_fee_per_gas, :string
      add :max_priority_fee_per_gas, :string
      add :nonce, :string
      add :to, :string
      add :value, :string
      add :status, :string, default: "pending"
    
      timestamps()
    end
  end
end



  