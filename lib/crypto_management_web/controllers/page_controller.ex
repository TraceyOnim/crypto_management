defmodule CryptoManagementWeb.PageController do
  use CryptoManagementWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
