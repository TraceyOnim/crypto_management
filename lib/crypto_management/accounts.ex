defmodule CryptoManagement.Accounts do
  @moduledoc """
  This module will be responsible for manipulating transaction data
  """
  alias CryptoManagement.Client
  alias CryptoManagement.Transaction
  alias CryptoManagement.Util

  @http_client Application.get_env(:crypto_management, :http_client, Client)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.
  """

  @spec change_transaction(%Transaction{}, map()) :: %Ecto.Changeset{}
  def change_transaction(transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
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

  defp parse_hex_to_decimal({:ok, result}) do
    case Util.parse_hex_to_decimal(result) do
      :error -> 0
      value -> value
    end
  end

  defp parse_hex_to_decimal(_), do: 0

  defp handle_response({:ok, %HTTPoison.Response{body: body, status_code: status_code}})
       when status_code in 200..399 do
    case Poison.decode(body) do
      {:ok, %{"result" => result}} -> {:ok, result}
      _ -> :error
    end
  end

  defp handle_response(_), do: :error
end
