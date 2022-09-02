defmodule CryptoManagement.ClientBehaviour do
  @callback get(action :: [String.t()], options :: [any()]) ::
              {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
              | {:error, HTTPoison.Error.t()}
end
