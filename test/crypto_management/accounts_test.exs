defmodule CryptoManagement.AccountsTest do
  use CryptoManagement.DataCase

  alias CryptoManagement.{Accounts, Transaction}

  describe "change_transaction/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_transaction(%Transaction{})

      assert changeset.required == [:hash]
    end

    test "allows fields to be set" do
      attrs = %{
        "hash" => "0x0d4ae469b46e663146dbe886af965e9f672cacfb75052e0b994a2fad5b4f4bdf",
        "block_number" => "0xebc758"
      }

      changeset = Accounts.change_transaction(%Transaction{}, attrs)

      assert changeset.valid?
      assert get_change(changeset, :hash) == attrs["hash"]
      assert get_change(changeset, :block_number) == attrs["block_number"]
    end

    test "requires hash to change" do
      changeset = Accounts.change_transaction(%Transaction{})

      assert %{hash: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
