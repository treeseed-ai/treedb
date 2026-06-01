defmodule TreeDbWeb.AuthPlug do
  @moduledoc false
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case TreeDb.Auth.authenticate_header(get_req_header(conn, "authorization") |> List.first()) do
      {:ok, principal} -> assign(conn, :principal, stringify(principal))
      {:error, error} -> assign(conn, :auth_error, error) |> assign(:principal, nil)
    end
  end

  defp stringify(nil), do: nil
  defp stringify(map), do: for({key, value} <- map, into: %{}, do: {to_string(key), value})
end
