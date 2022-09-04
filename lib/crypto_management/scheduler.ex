defmodule CryptoManagement.Scheduler do
  use GenServer

  require Logger

  alias CryptoManagement.Accounts
  alias CryptoManagement.TransactionCache
  alias alias Phoenix.PubSub

  # client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # server

  @impl true

  def init(opts) do
    # cache all pending transaction 
    insert_all_transaction()
    schedule_work()

    {:ok, opts}
  end

  @impl true
  def handle_info(:update, state) do
    update_pending_transactions()
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :update, 20000)
  end

  defp confirmed_transactions(recent_block_number, cached_transactions) do
    Enum.filter(cached_transactions, fn key ->
      transaction = Transaction.Cache.get(key)
      confirmed_blocks = recent_block_number - transaction.block_number
      confirmed_blocks >= 2
    end)
  end

  defp update_pending_transactions do
    all_cached_transactions = TransactionCache.all_cached_transactions()

    unless Enum.empty?(all_cached_transactions) do
      confirmed_transactions =
        Accounts.recent_block_number() |> confirmed_transactions(all_cached_transactions)

      Accounts.update_pending_transactions(confirmed_transactions)
      # broadcast updated transactions
      PubSub.broadcast(
        CryptoManagement.PubSub,
        "updated_transactions",
        {:updated_transactions, confirmed_transactions}
      )

      # delete cached transactions after update in the db
      TransactionCache.delete_transaction(confirmed_transactions)
    else
      Logger.info("There is no pending transactions")
    end
  end

  defp insert_all_transaction do
    pending_transactions = Accounts.all_pending_transactions()

    unless Enum.empty?(pending_transactions) do
      TransactionCache.insert_all_transaction(pending_transactions)
    else
      Logger.info("There is no pending transactions")
    end
  end
end
