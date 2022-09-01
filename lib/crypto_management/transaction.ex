defmodule CryptoManagement.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  @primary_key {:hash, :binary_id, autogenerate: false}

  schema "transactions" do
    field :block_hash, :string
    field :block_number, :string
    field :chain_id, :string
    field :from, :string
    field :gas, :string
    field :gas_price, :string
    field :input, :string
    field :max_fee_per_gas, :string
    field :max_priority_fee_per_gas, :string
    field :nonce, :string
    field :to, :string
    field :value, :string
    field :status, :string, default: "pending"

    timestamps()
  end

  @fields ~w(hash block_hash block_number chain_id from gas gas_price input max_fee_per_gas max_priority_fee_per_gas nonce to value status)a

  def changeset(transaction \\ %Transaction{}, attrs \\ %{}) do
    transaction
    |> cast(attrs, @fields)
    |> validate_required([:hash])
  end
end
