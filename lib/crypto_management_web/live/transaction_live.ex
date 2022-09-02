defmodule CryptoManagementWeb.TransactionLive do
  use CryptoManagementWeb, :live_view

  alias CryptoManagement.{Accounts, Transaction}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, changeset: Accounts.change_transaction(%Transaction{}))}
  end

  def render(assigns) do
    ~H"""
      <.form let={f} for={@changeset} phx-change="validate" phx-submit="submit" >
        <%= label f, :enter_transaction_hash %>
        <%= text_input f, :hash, phx_debounce: "blur" %>
        <%= error_tag f, :hash %>
        <%= submit "Submit" %>
      </.form>
    """
  end

  @impl true
  def handle_event("validate", %{"transaction" => params}, socket) do
    changeset =
      %Transaction{}
      |> Accounts.change_transaction(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("submit", %{"transaction" => params}, socket) do
    # fetch the transaction->done
    # sanitize the transaction params -> done
    # fetch recent block number->done
    # convert block number from hex to decimal-> done
    # save transaction in the db->done
    # save transaction locally -> done
    # index transaction
    # show
    # schedule job to update
    case CryptoManagement.Accounts.save_transaction(params) do
      {:ok, _transaction} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Transaction created successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {:error, message} ->
        {
          :noreply,
          socket
          |> put_flash(:error, message)
        }
    end
  end
end
