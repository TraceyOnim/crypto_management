defmodule CryptoManagement.Util do
  # For compatibility with Parity, please prefix all hex strings with " 0x "
  def prefix_hex("0x" <> _hex = value), do: value
  def prefix_hex(value), do: "0x" <> value

  def parse_hex_to_decimal("0x" <> hex) do
    case Integer.parse(hex, 16) do
      {value, _} -> value
      _ -> :error
    end
  end

  def sanitize_keys(params) do
    params
    |> Enum.map(fn {k, v} -> {Macro.underscore(k), v} end)
    |> Map.new()
  end
end
