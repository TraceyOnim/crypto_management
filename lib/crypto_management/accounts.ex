defmodule CryptoManagement.Accounts do
  @moduledoc """
  This module will be responsible for manipulating transaction data
  """
  alias CryptoManagement.Client
  alias CryptoManagement.Transaction
  alias CryptoManagement.TransactionCache
  alias CryptoManagement.Util
  alias CryptoManagement.Repo

  @http_client Application.get_env(:crypto_management, :http_client, Client)

  def save_transaction(%{"hash" => hash} = attrs) do
    with %Ecto.Changeset{valid?: true} <- change_transaction(%Transaction{}, attrs),
         {:ok, transaction} <- get_eth_transaction(hash),
         :ok <- TransactionCache.insert_transaction(transaction),
         {:ok, transaction} <- create_transaction(transaction) do
      {:ok, transaction}
    else
      %Ecto.Changeset{valid?: false} = changeset ->
        Ecto.Changeset.apply_action(changeset, :insert)

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, "Something went wrong, confirm the hash entered and Try Again!!!"}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.
  """

  @spec change_transaction(%Transaction{}, map()) :: %Ecto.Changeset{}
  def change_transaction(transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  @doc """
  inserts a transaction into the database
  """
  @spec create_transaction(map()) :: {:ok, %Transaction{}} | {:error, %Ecto.Changeset{}}
  def create_transaction(params) do
    params = new_param(params)

    %Transaction{}
    |> change_transaction(params)
    |> Repo.insert()
  end

  @doc """
  Returns the information about a transaction requested by transaction hash.
  """
  @spec get_eth_transaction(String.t()) :: {:ok, map()} | :error
  def get_eth_transaction(hash) do
    "eth_getTransactionByHash"
    |> @http_client.get(hash: Util.prefix_hex(hash))
    |> handle_response()
  end

  @doc """
  Returns the number of most recent block
  """
  @spec recent_block_number() :: integer()
  def recent_block_number do
    "eth_blockNumber"
    |> @http_client.get([])
    |> handle_response()
    |> parse_hex_to_decimal()
  end

  @doc """
  Fetches all transaction from db
  """
  @spec all_transactions() :: [%Transaction{}, ...]
  def all_transactions do
    Repo.all(Transaction)
  end

  @doc """
  Returns transaction of the given hash from database
  """
  @spec get_transaction(String.t()) :: %Transaction{}
  def get_transaction(hash) do
    Repo.get(Transaction, hash)
  end

  defp parse_hex_to_decimal({:ok, result}) do
    Util.parse_hex_to_decimal(result)
  end

  defp parse_hex_to_decimal(_), do: 0

  defp new_param(params) do
    params = Util.sanitize_keys(params)
    Map.put(params, "block_number", Util.parse_hex_to_decimal(params["block_number"]))
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body, status_code: status_code}})
       when status_code in 200..399 do
    case Poison.decode(body) do
      {:ok, %{"result" => result}} -> {:ok, result}
      _ -> :error
    end
  end

  defp handle_response(_), do: :error
end
