defmodule CryptoManagement.Client do
  @behaviour CryptoManagement.ClientBehaviour
  @moduledoc """
  The Client context will be responsible for communicating with the Etherscan API.
  """
  require Logger
  @base_url "https://api.etherscan.io/api"
  @api_key System.get_env("ETHERSCAN_API_KEY") ||
             raise("""
             environment variable ETHERSCAN_API_KEY is missing.
             """)
  @header [{"content-Type", "application/json"}]

  def get(action, options \\ []) do
    action
    |> url(options)
    |> HTTPoison.get(@header)
  end

  defp url("eth_getTransactionByHash" = action, options) do
    case options[:hash] do
      nil -> Logger.error("Invalid argument, hash is missing")
      hash -> "#{@base_url}?module=proxy&action=#{action}&txhash=#{hash}&apikey=#{@api_key}"
    end
  end

  defp url("eth_blockNumber" = action, _options) do
    "#{@base_url}?module=proxy&action=#{action}&apikey=#{@api_key}"
  end

  defp url(_action, _options) do
    @base_url
  end
end
