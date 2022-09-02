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
    # save transaction in the db
    # save transaction locally
    case CryptoManagement.Accounts.change_transaction(%Transaction{}, params)
         |> CryptoManagement.Repo.insert() do
      {:ok, event} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Transaction created successfully")
          |> push_redirect(to: "/")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
