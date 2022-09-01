defmodule CryptoManagement.Accounts do
  @moduledoc """
  This module will be responsible for manipulating transaction data
  """
  alias CryptoManagement.Transaction

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """

  def change_transaction(transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
