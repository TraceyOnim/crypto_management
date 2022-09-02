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

      assert %{hash: ["Oops! tx hash is empty. Try Again"]} = errors_on(changeset)
    end

    test "hash length should be 64" do
      changeset = Accounts.change_transaction(%Transaction{}, %{hash: "0xca8b863caa"})
      assert %{hash: ["invalid hash, should be 64 character(s)"]} = errors_on(changeset)
    end
  end

  describe "get_eth_transaction/2" do
    setup do
      invalid_response =
        {:ok,
         %HTTPoison.Response{
           body:
             "{\"jsonrpc\":\"2.0\",\"id\":1,\"error\":{\"code\":-32602,\"message\":\"invalid argument 0: json: cannot unmarshal invalid hex string into Go value of type common.Hash\"}}\n",
           headers: [
             {"Server", "nginx"},
             {"Date", "Fri, 02 Sep 2022 01:57:17 GMT"},
             {"Content-Type", "application/json; charset=utf-8"},
             {"Content-Length", "157"},
             {"Connection", "keep-alive"},
             {"Cache-Control", "private"},
             {"Access-Control-Allow-Origin", "*"},
             {"Access-Control-Allow-Headers", "Content-Type"},
             {"Access-Control-Allow-Methods", "GET, POST, OPTIONS"},
             {"X-Frame-Options", "SAMEORIGIN"}
           ],
           request: %HTTPoison.Request{
             body: "",
             headers: [{"content-Type", "application/json"}],
             method: :get,
             options: [],
             params: %{},
             url:
               "https://api.etherscan.io/api?module=proxy&action=eth_getTransactionByHash&txhash=0x0d4ae469b46e663146dbe886af965e9f672cacfb75052e0b994a2fad5b4f4bdo&apikey=4JKZNYDPTAHSH3A8AE7FTG7SXDNEDZ9JVS"
           },
           request_url:
             "https://api.etherscan.io/api?module=proxy&action=eth_getTransactionByHash&txhash=0x0d4ae469b46e663146dbe886af965e9f672cacfb75052e0b994a2fad5b4f4bdo&apikey=4JKZNYDPTAHSH3A8AE7FTG7SXDNEDZ9JVS",
           status_code: 200
         }}

      valid_response =
        {:ok,
         %HTTPoison.Response{
           body:
             "{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":{\"blockHash\":\"0xca8b863caa24d250b5ef9733110a0dc31c63a6178eee5ff36c7f259f170eef3b\",\"blockNumber\":\"0xebc758\",\"from\":\"0x3c16183c1c0e28f1a0cb9f8ee4b21d0db208ca46\",\"gas\":\"0x186a0\",\"gasPrice\":\"0x3653e98f8\",\"maxFeePerGas\":\"0x684ee1800\",\"maxPriorityFeePerGas\":\"0x3b9aca00\",\"hash\":\"0x0d4ae469b46e663146dbe886af965e9f672cacfb75052e0b994a2fad5b4f4bdf\",\"input\":\"0x\",\"nonce\":\"0xc1921\",\"to\":\"0xd27bb47fc504c75f2fa2927c1f66d5a38dfa2ca4\",\"transactionIndex\":\"0x7a\",\"value\":\"0x36873023485ba00\",\"type\":\"0x2\",\"accessList\":[],\"chainId\":\"0x1\",\"v\":\"0x0\",\"r\":\"0xd56b8a193465b0ff4f7d6cb29702175ce86a68f068a895d1eb19379f5df7a8c0\",\"s\":\"0x6bfedb8b38efbf721ce31f7edf225a219a98a5d83ee2bafca118e7cc7dc655e7\"}}\n",
           headers: [
             {"Server", "nginx"},
             {"Date", "Fri, 02 Sep 2022 00:30:52 GMT"},
             {"Content-Type", "application/json; charset=utf-8"},
             {"Content-Length", "712"},
             {"Connection", "keep-alive"},
             {"Cache-Control", "private"},
             {"Access-Control-Allow-Origin", "*"},
             {"Access-Control-Allow-Headers", "Content-Type"},
             {"Access-Control-Allow-Methods", "GET, POST, OPTIONS"},
             {"X-Frame-Options", "SAMEORIGIN"}
           ],
           request: %HTTPoison.Request{
             body: "",
             headers: [{"content-Type", "application/json"}],
             method: :get,
             options: [],
             params: %{},
             url:
               "https://api.etherscan.io/api?module=proxy&action=eth_getTransactionByHash&txhash=0x0d4ae469b46e663146dbe886af965e9f672cacfb75052e0b994a2fad5b4f4bdf&apikey=4JKZNYDPTAHSH3A8AE7FTG7SXDNEDZ9JVS"
           },
           request_url:
             "https://api.etherscan.io/api?module=proxy&action=eth_getTransactionByHash&txhash=0x0d4ae469b46e663146dbe886af965e9f672cacfb75052e0b994a2fad5b4f4bdf&apikey=4JKZNYDPTAHSH3A8AE7FTG7SXDNEDZ9JVS",
           status_code: 200
         }}

      [invalid_response: invalid_response, valid_response: valid_response]
    end

    test "returns transaction of the given hash", %{valid_response: response} do
      Mox.stub(CryptoManagement.HttpClientMock, :get, fn _action, _options ->
        response
      end)

      hash = "0x0d4ae469b46e663146dbe886af965e9f672cacfb75052e0b994a2fad5b4f4bdf"

      {:ok, result} = Accounts.get_eth_transaction(hash)

      assert result["hash"] == hash
    end

    test "returns an error for invalid hash", %{invalid_response: response} do
      Mox.stub(CryptoManagement.HttpClientMock, :get, fn _action, _options ->
        response
      end)

      hash = "0x0d4ae469b46e663"

      assert Accounts.get_eth_transaction(hash) == :error
    end
  end

  describe "recent_block_number/0" do
    setup do
      response =
        {:ok,
         %HTTPoison.Response{
           body: "{\"jsonrpc\":\"2.0\",\"id\":83,\"result\":\"0xebd996\"}\n",
           headers: [
             {"Server", "nginx"},
             {"Date", "Fri, 02 Sep 2022 02:53:47 GMT"},
             {"Content-Type", "application/json; charset=utf-8"},
             {"Content-Length", "46"},
             {"Connection", "keep-alive"},
             {"Cache-Control", "private"},
             {"Access-Control-Allow-Origin", "*"},
             {"Access-Control-Allow-Headers", "Content-Type"},
             {"Access-Control-Allow-Methods", "GET, POST, OPTIONS"},
             {"X-Frame-Options", "SAMEORIGIN"}
           ],
           request: %HTTPoison.Request{
             body: "",
             headers: [{"content-Type", "application/json"}],
             method: :get,
             options: [],
             params: %{},
             url:
               "https://api.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey=4JKZNYDPTAHSH3A8AE7FTG7SXDNEDZ9JVS"
           },
           request_url:
             "https://api.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey=4JKZNYDPTAHSH3A8AE7FTG7SXDNEDZ9JVS",
           status_code: 200
         }}

      [response: response]
    end

    test "returns block number of the recent block", %{response: response} do
      Mox.stub(CryptoManagement.HttpClientMock, :get, fn _action, _options ->
        response
      end)

      {:ok, res} = response
      block_number = Accounts.recent_block_number()
      {:ok, %{"result" => result}} = Poison.decode(res.body)
      assert convert_decimal_to_hex(block_number) == result
    end
  end

  defp convert_decimal_to_hex(number) do
    hex = number |> Integer.to_string(16) |> String.downcase()
    "0x" <> hex
  end
end
