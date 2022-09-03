defmodule CryptoManagementWeb.TransactionLiveTest do
  use CryptoManagementWeb.ConnCase, async: true
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  describe "user submits transaction hash" do
    setup %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

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

      [html: html, view: view, valid_response: valid_response, invalid_response: invalid_response]
    end

    test "user can see form for submitting tx hash", %{html: html} do
      assert html =~ "Enter transaction hash"
    end

    test "transaction is saved for valid hash", %{view: view, valid_response: response} do
      Mox.stub(CryptoManagement.HttpClientMock, :get, fn _action, _options ->
        response
      end)

      param = %{"hash" => "0x0d4ae469b46e663146dbe886af965e9f672cacfb75052e0b994a2fad5b4f4bdf"}

      assert render_submit(view, :submit, %{"transaction" => param}) =~
               "Transaction created successfully"
    end

    test "hash given is validated", %{view: view} do
      param = %{"hash" => "0x0d4ae469b4"}

      assert render_submit(view, :submit, %{"transaction" => param}) =~
               "invalid hash, should be 64-66 character(s)"
    end

    test "fails to save for invalid response", %{view: view, invalid_response: response} do
      Mox.stub(CryptoManagement.HttpClientMock, :get, fn _action, _options ->
        response
      end)

      param = %{"hash" => "12c70712d0a7e0c0faa59cc023b5ce532c008a17c942db32a53da435ea7e7613c9"}

      assert render_submit(view, :submit, %{"transaction" => param}) =~
               "Something went wrong, confirm the hash entered and Try Again!!!"
    end
  end
end
