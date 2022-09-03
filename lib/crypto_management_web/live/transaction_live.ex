defmodule CryptoManagementWeb.TransactionLive do
  use CryptoManagementWeb, :live_view

  alias Phoenix.LiveView.JS
  alias CryptoManagement.{Accounts, Transaction}

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       modal: false,
       transactions: Accounts.all_transactions(),
       changeset: Accounts.change_transaction(%Transaction{})
     )}
  end

  def render(assigns) do
    ~H"""
      <.form let={f} for={@changeset} phx-change="validate" phx-submit="submit" >
        <%= label f, :enter_transaction_hash %>
        <%= text_input f, :hash, phx_debounce: "blur" %>
        <%= error_tag f, :hash %>
        <%= submit "Submit" %>
      </.form>
      <div>
      <h2>Transactions</h2>
      <table>
        <thead>
          <tr>
            <th >Hash</th>            
            <th >Block number</th>    
            <th >status</th>
          </tr>
        </thead>
        <tbody>
          <%= for transaction <- @transactions do %>
            <tr>
              <td><%= transaction.hash %></td>            
              <td><%= transaction.block_number %></td> 
              <td><%= transaction.status %></td>
              <td><button phx-click="more"  phx-value-hash={transaction.hash} >more</button></td>
            </tr>
          <% end %>
        </tbody>
      </table>
      <%= if @modal do %>
      <.modal return_to={Routes.live_path(@socket, CryptoManagementWeb.TransactionLive)} >
        <ul>
          <li>Transactions Hash: <%= @transaction.hash %></li>
          <li>Status: <%= @transaction.status %></li>
          <li>Block Hash: <%= @transaction.block_hash %></li>
          <li>Block Number: <%= @transaction.block_number %></li>
          <li>Chain ID: <%= @transaction.chain_id %></li>
          <li>From: <%= @transaction.from %></li>
          <li>To: <%= @transaction.to %></li>
          <li>Gas: <%= @transaction.gas %></li>
          <li>Gas Price: <%= @transaction.gas_price %></li>
          <li>Max Fee Per Gas: <%= @transaction.max_fee_per_gas %></li>
          <li>Max Priority Fee Per Gas: <%= @transaction.max_priority_fee_per_gas %></li>
          <li>Nonce: <%= @transaction.nonce %></li>
          <li>Value: <%= @transaction.value %></li>

        </ul> 
      </.modal>
      <% end %>
      </div>
    """
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, modal: false)}
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
    # index transaction -> done
    # show -> done
    # schedule job to update
    case CryptoManagement.Accounts.save_transaction(params) do
      {:ok, transaction} ->
        {
          :noreply,
          socket
          |> assign(transactions: socket.assigns.transactions ++ [transaction])
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

  @impl true
  def handle_event("more", %{"hash" => hash}, socket) do
    {:noreply, assign(socket, modal: true, transaction: Accounts.get_transaction(hash))}
  end

  defp modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <%= live_patch("✖",
            to: @return_to,
            id: "close",
            class: "phx-modal-close",
            phx_click: hide_modal()
          ) %>
        <% else %>
          <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>&times;</a>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end
end
