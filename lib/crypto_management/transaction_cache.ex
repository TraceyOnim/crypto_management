defmodule CryptoManagement.TransactionCache do
  @moduledoc """
  context for manipulating cache entries. It involves;
   - Inserting a transaction 
   - Fetching transaction whose block confirmation is `>=2` 
   - Deleting confirmed transaction from the cache 
  """
  import Transaction.Cache
  alias CryptoManagement.Util

  def insert_transaction(transaction) do
    transaction = new_transaction(transaction)

    case put(transaction[:id], transaction) do
      :ok -> :ok
      _ -> :error
    end
  end

  def confirmed_transactions(recent_block_number) do
    cached_transactions_keys = all()

    Enum.filter(cached_transactions_keys, fn key ->
      transaction = Transaction.Cache.get(key)
      confirmed_blocks = recent_block_number - transaction.block_number
      confirmed_blocks >= 2
    end)
  end

  def delete_transaction(confirmed_transactions) do
    unless Enum.empty?(confirmed_transactions) do
      Enum.each(confirmed_transactions, fn key -> delete(key) end)
    end
  end

  defp new_transaction(transaction) do
    transaction = Util.sanitize_keys(transaction)

    %{
      id: transaction["hash"],
      block_number: Util.parse_hex_to_decimal(transaction["block_number"])
    }
  end
end
