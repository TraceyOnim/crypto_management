defmodule CryptoManagement.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  @primary_key {:hash, :string, autogenerate: false}

  schema "transactions" do
    field :block_hash, :string
    field :block_number, :integer
    field :chain_id, :string
    field :from, :string
    field :gas, :string
    field :gas_price, :string
    field :max_fee_per_gas, :string
    field :max_priority_fee_per_gas, :string
    field :nonce, :string
    field :to, :string
    field :value, :string
    field :status, :string, default: "pending"

    timestamps()
  end

  @fields ~w(hash block_hash block_number chain_id from gas gas_price max_fee_per_gas max_priority_fee_per_gas nonce to value status)a

  def changeset(transaction \\ %Transaction{}, attrs \\ %{}) do
    transaction
    |> cast(attrs, @fields)
    |> validate_required([:hash], message: "Oops! tx hash is empty. Try Again")
    |> validate_length(:hash,
      min: 64,
      max: 66,
      message: "invalid hash, should be 64-66 character(s)"
    )
    |> unique_constraint(:hash,
      name: :transactions_pkey,
      message: "Transaction with the given hash already exist"
    )
  end
end
