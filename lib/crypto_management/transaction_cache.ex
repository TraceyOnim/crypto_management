defmodule CryptoManagement.TransactionCache do
  @moduledoc """
  context for manipulating cache entries. It involves;
   - Inserting a pending transaction into the cache
   - Fetching transaction whose block confirmation is `>=2` 
   - Deleting confirmed transaction from the cache 
  """
  alias CryptoManagement.Accounts
  alias Transaction.Cache
  alias CryptoManagement.Util

  def insert_transaction(transaction) do
    Cache.put(transaction["hash"], new_transaction(transaction))
  end

  def insert_all_transaction(pending_transactions) do
    pending_transactions
    |> Enum.map(fn transaction ->
      {transaction.hash, %{id: transaction.hash, block_number: transaction.block_number}}
    end)
    |> Cache.put_all()
  end

  def confirmed_transactions(recent_block_number) do
    cached_transactions_keys = Cache.all()

    Enum.filter(cached_transactions_keys, fn key ->
      transaction = Cache.get(key)
      confirmed_blocks = recent_block_number - transaction.block_number
      confirmed_blocks >= 2
    end)
  end

  def delete_transaction(value) when is_list(value) do
    unless Enum.empty?(value) do
      Enum.each(value, fn key -> delete_transaction(key) end)
    end
  end

  def delete_transaction(value) do
    Cache.delete(value)
  end

  defp new_transaction(transaction) do
    transaction = Util.sanitize_keys(transaction)

    %{
      id: transaction["hash"],
      block_number: Util.parse_hex_to_decimal(transaction["block_number"])
    }
  end
end
